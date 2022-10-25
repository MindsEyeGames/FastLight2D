using UnityEngine;

namespace MEG.FL2D
{
    [RequireComponent(typeof(Camera))]
    public class FastLight2DManager : MonoBehaviour
    {
        [SerializeField] private Camera _shadowMapCamera;
        public Camera ShadowMapCamera
        {
            get { return _shadowMapCamera; }
            set { _shadowMapCamera = value; }
        }
        public RenderTexture ShadowMap => ShadowMapCamera.targetTexture;
        public int MaxLights => ShadowMap.height;

        [SerializeField] private GlobalShaderRenderTex _shadowMapBinding = new GlobalShaderRenderTex();
        public GlobalShaderRenderTex ShadowMapBinding
        {
            get { return _shadowMapBinding; }
            set { _shadowMapBinding = value; }
        }

        #region LightData
        [SerializeField] private GlobalShaderTexture _lightDataBinding = new GlobalShaderTexture();
        public GlobalShaderTexture LightDataBinding
        {
            get { return _lightDataBinding; }
            set { _lightDataBinding = value; }
        }

        public static readonly int LIGHT_DATA_WIDTH = 4;
        public Texture2D LightDataTex { get; private set; }
        public Color[] LightData { get; private set; }
        public virtual void SetLightData(int lightIndex, float xVal, float yVal, float rVal, int layer)
        {
            int i = lightIndex * LIGHT_DATA_WIDTH;
            LightData[i + 0] = ShaderDataPassing.FloatToColor(xVal);
            LightData[i + 1] = ShaderDataPassing.FloatToColor(yVal);
            LightData[i + 2] = ShaderDataPassing.FloatToColor(rVal);
            LightData[i + 3] = ShaderDataPassing.Int32ToColor(1 << layer);
        }

        [SerializeField] private GlobalShaderFloat _maxLightYBinding = new GlobalShaderFloat();
        public GlobalShaderFloat MaxLightYBinding
        {
            get { return _maxLightYBinding; }
            set { _maxLightYBinding = value; }
        }
        public float MaxLightY
        {
            get { return MaxLightYBinding.Value; }
            set { MaxLightYBinding.Value = value; }
        }

        [SerializeField] private GlobalShaderFloat _lightRadiusFactorBinding = new GlobalShaderFloat();
        public GlobalShaderFloat LightRadiusFactorBinding
        {
            get { return _lightRadiusFactorBinding; }
            set { _lightRadiusFactorBinding = value; }
        }
        public float LightRadiusFactor
        {
            get { return LightRadiusFactorBinding.Value; }
            set { LightRadiusFactorBinding.Value = value; }
        }

        [SerializeField] private GlobalShaderV4 _lightBoundsRectBinding = new GlobalShaderV4();
        public GlobalShaderV4 LightBoundsRectBinding
        {
            get { return _lightBoundsRectBinding; }
            set { _lightBoundsRectBinding = value; }
        }
        public Vector4 LightBoundsRect
        {
            get { return LightBoundsRectBinding.Vector; }
            set { LightBoundsRectBinding.Vector = value; }
        }

        #endregion

        public virtual void OnEnable()
        {
            if (ShadowMap == null)
            {
                // The shadow map camera's render texture not only is how this whole thing works,
                // but its dimensions also drive many internal values:
                //   * WIDTH: angular resolution of the shadow map
                //   * HEIGHT the maximum number of lights-with-shadows supported
                Debug.LogError("THE SHADOW MAP CAMERA -MUST- HAVE A RENDER TEXTURE APPLIED!");
                ShadowMapCamera.enabled = false;
                return;
            }

            LightDataTex = new Texture2D(LIGHT_DATA_WIDTH, MaxLights, TextureFormat.RGBA32, false);
            LightDataTex.filterMode = FilterMode.Point;
            LightDataTex.name = "Light Data Lookup Map";
            LightData = new Color[MaxLights * LIGHT_DATA_WIDTH];
            LightDataTex.SetPixels(LightData);
            LightDataTex.Apply();

            LightDataBinding.Texture = LightDataTex;
            LightDataBinding.Apply();

            ShadowMapBinding.Texture = ShadowMap;
            ShadowMapBinding.Apply();

            MaxLightY = 0;
            MaxLightYBinding.Apply();

            LightRadiusFactorBinding.Apply();

            LightBoundsRectBinding.Apply();
        }

        public virtual void LateUpdate()
        {
            ShadowMapCamera.enabled = FastLight2D.ActiveLights.Count > 0;
            if (!ShadowMapCamera.enabled) return;

            Rect bounds = GetActiveLightBounds();
            float maxR = GetMaxLightRadius() + 1f;

            MaxLightY = Mathf.Clamp01(FastLight2D.ActiveLights.Count / (float)MaxLightY);
            LightRadiusFactor = maxR;
            LightBoundsRect = new Vector4(bounds.xMin, bounds.yMin, bounds.width, bounds.height);

            Vector3 pos = ShadowMapCamera.transform.position;
            pos.x = bounds.center.x;
            pos.y = bounds.center.y;
            ShadowMapCamera.transform.position = pos;
            ShadowMapCamera.orthographicSize = bounds.height / 2;
            ShadowMapCamera.aspect = bounds.width / bounds.height;

            PopulateLightData(bounds, maxR);
        }

        protected virtual Rect GetActiveLightBounds()
        {
            if (FastLight2D.ActiveLights.Count == 0) return default;

            FastLight2D light = FastLight2D.ActiveLights[0];
            Vector3 pos = light.transform.position;
            float r = light.Radius;

            float xMin = pos.x - r;
            float yMin = pos.y - r;
            float xMax = pos.x + r;
            float yMax = pos.y + r;

            for(int i = 1; i < Mathf.Min(FastLight2D.ActiveLights.Count, MaxLights); i++)
            {
                light = FastLight2D.ActiveLights[i];
                pos = light.transform.position;
                r = light.Radius;

                xMin = Mathf.Min(xMin, pos.x - r);
                yMin = Mathf.Min(yMin, pos.y - r);
                xMax = Mathf.Max(xMax, pos.x + r);
                yMax = Mathf.Max(yMax, pos.y + r);
            }

            return Rect.MinMaxRect(xMin, yMin, xMax, yMax);
        }

        protected virtual float GetMaxLightRadius()
        {
            if (FastLight2D.ActiveLights.Count == 0) return 1f;

            float r = FastLight2D.ActiveLights[0].Radius;
            for (int i = 1; i < Mathf.Min(FastLight2D.ActiveLights.Count, MaxLights); i++)
            {
                r = Mathf.Max(r, FastLight2D.ActiveLights[i].Radius);
            }
            return r;
        }

        protected virtual void PopulateLightData(Rect bounds, float maxRadius)
        {
            float baseX = bounds.xMin;
            float baseY = bounds.yMin;
            float width = bounds.width;
            float height = bounds.height;

            // If we DO have too many lights, ensure high-priority lights get their shadows.
            // NOTE: This shadow method *should* scale to quite a few lights unless you truly
            // have a very large number (or are running out of vertical texture size).
            if (FastLight2D.ActiveLights.Count > MaxLights) FastLight2D.SortByProprity();

            for (int i = 0; i < Mathf.Min(FastLight2D.ActiveLights.Count, MaxLights); i++)
            {
                FastLight2D light = FastLight2D.ActiveLights[i];
                Vector3 pos = light.transform.position;
                SetLightData(i,
                    Mathf.Clamp01((pos.x - baseX) / width),
                    Mathf.Clamp01((pos.y - baseY) / height),
                    Mathf.Clamp01(light.Radius / maxRadius),
                    light.gameObject.layer);
                light.SetLightData((i + 0.5f) / MaxLights, true);
            }

            // Any overflow will just automatically have its lights disabled.
            for(int i = MaxLights; i < FastLight2D.ActiveLights.Count; i++)
                FastLight2D.ActiveLights[i].SetLightData(0, false);

            LightDataTex.SetPixels(LightData);
            LightDataTex.Apply();

            MaxLightY = Mathf.Clamp01(((float)FastLight2D.ActiveLights.Count) / MaxLights);
        }

        public virtual void OnDisable()
        {
            LightDataBinding.Revoke();
            ShadowMapBinding.Revoke();
            MaxLightYBinding.Revoke();
            LightRadiusFactorBinding.Revoke();
            LightBoundsRectBinding.Revoke();
        }
    }
}