using System.Collections.Generic;
using UnityEngine;

namespace MEG.FL2D
{
    public class FastLight2D : MonoBehaviour
    {
        public static List<FastLight2D> ActiveLights { get; private set; } = new List<FastLight2D>();
        public static void SortByProprity()
        {
            ActiveLights.Sort((a, b) =>
            {
                if(a.ShadowPriority != b.ShadowPriority) return -a.ShadowPriority.CompareTo(b.ShadowPriority);
                return -a.Radius.CompareTo(b.Radius);
            });
        }

        [SerializeField] private MeshFilter _meshFilter;
        public MeshFilter Filter
        {
            get { return _meshFilter; }
            set { _meshFilter = value; }
        }

        [SerializeField] private MeshRenderer _renderer;
        public MeshRenderer Renderer
        {
            get { return _renderer; }
            set { _renderer = value; }
        }

        [Space(10)]

        #region Shadow Priority and Enabling
        [SerializeField] private int _shadowPriority = 0;
        public int ShadowPriority
        {
            get { return _shadowPriority; }
            set { _shadowPriority = value; } // No change detection needed, for simplicity the manager sorts every rendered frame
        }

        [SerializeField] private bool _shadowsEnabled = true;
        public bool ShadowsEnabled
        {
            get { return _shadowsEnabled; }
            set
            {
                if (_shadowsEnabled != value)
                {
                    _shadowsEnabled = value;
                    if (Properties != null)
                    {
                        PushShadowStrengthToProperties();
                        ApplyProperties();
                    }
                }
            }
        }

        [SerializeField] private string _shadowStrengthProperty = "_Shadow_Strength";
        public string ShadowStrengthProperty
        {
            get { return _shadowStrengthProperty; }
            set
            {
                if (_shadowStrengthProperty != value)
                {
                    _shadowStrengthProperty = value;
                    if (Properties != null)
                    {
                        PushShadowStrengthToProperties();
                        ApplyProperties();
                    }
                }
            }
        }

        protected virtual void PushShadowStrengthToProperties()
        {
            Properties.SetFloat(ShadowStrengthProperty, ShadowsEnabled ? 1f: 0f);
        }
        #endregion

        [Space(10)]

        #region Radius
        [SerializeField] private float _radius = 1f;
        public float Radius
        {
            get { return _radius; }
            set
            {
                if (_radius != value)
                {
                    _radius = value;
                    transform.localScale = value * Vector3.one;
                }
            }
        }
        #endregion

        [Space(10)]

        #region Color
        [SerializeField] private Color _color = new Color();
        public Color Color
        {
            get { return _color; }
            set
            {
                if (_color != value)
                {
                    _color = value;
                    if (Properties != null)
                    {
                        PushColorToProperties();
                        ApplyProperties();
                    }
                }
            }
        }

        [SerializeField] private string _colorProperty = "_Color";
        public string ColorProperty
        {
            get { return _colorProperty; }
            set
            {
                if (_colorProperty != value)
                {
                    _colorProperty = value;
                    if (Properties != null)
                    {
                        PushColorToProperties();
                        ApplyProperties();
                    }
                }
            }
        }

        protected virtual void PushColorToProperties()
        {
            Properties.SetColor(ColorProperty, Color);
        }
        #endregion

        [Space(10)]

        #region Light Data
        [SerializeField] private float _lightDataY = 0f;
        public float LightDataY
        {
            get { return _lightDataY; }
            set
            {
                if (_lightDataY != value)
                {
                    _lightDataY = value;
                    if (Properties != null)
                    {
                        PushLightDataYToProperties();
                        ApplyProperties();
                    }
                }
            }
        }

        [SerializeField] private string _lightDataYProperty = "_Light_Data_Y";
        public string LightDataYProperty
        {
            get { return _lightDataYProperty; }
            set
            {
                if (_lightDataYProperty != value)
                {
                    _lightDataYProperty = value;
                    if (Properties != null)
                    {
                        PushLightDataYToProperties();
                        ApplyProperties();
                    }
                }
            }
        }

        protected virtual void PushLightDataYToProperties()
        {
            Properties.SetFloat(LightDataYProperty, LightDataY);
        }
        #endregion

        public virtual void SetLightData(float lightDataY, bool shadowEnabled)
        {
            if (_lightDataY != lightDataY || _shadowsEnabled != shadowEnabled)
            {
                _lightDataY = lightDataY;
                _shadowsEnabled = shadowEnabled;

                if (Properties != null)
                {
                    PushLightDataYToProperties();
                    PushShadowStrengthToProperties();
                    ApplyProperties();
                }
            }
        }

        public MaterialPropertyBlock Properties { get; private set; }
        protected virtual MaterialPropertyBlock InitProperties()
        {
            MaterialPropertyBlock properties = new MaterialPropertyBlock();
            Renderer.GetPropertyBlock(properties);

            return properties;
        }

        public virtual void ApplyProperties()
        {
            if (Properties != null) Renderer.SetPropertyBlock(Properties);
        }

        public virtual void RefreshAllLightValues()
        {
            if (Properties == null) Properties = InitProperties();
            transform.localScale = Vector3.one * Radius;
            PushColorToProperties();
            PushLightDataYToProperties();
            PushShadowStrengthToProperties();
            ApplyProperties();
        }

        public virtual void OnEnable()
        {
            ActiveLights.Add(this);

            Filter.mesh = Meshes.SIMPLE_LIGHT_QUAD.Get();
            RefreshAllLightValues();
        }

        public virtual void OnDisable()
        {
            ActiveLights.Remove(this);
        }

        public virtual void OnDrawGizmosSelected()
        {
            Gizmos.color = Color;

            Vector3 pos = transform.position;

            int numPoints = 32;
            float rad = 2 * Mathf.PI / numPoints;
            for(int i = 1; i < numPoints; i += 2)
            {
                float r0 = rad * (i - 1);
                float r1 = rad * i;
                Gizmos.DrawLine(
                    pos + new Vector3(Mathf.Cos(r0), Mathf.Sin(r0), 0) * Radius,
                    pos + new Vector3(Mathf.Cos(r1), Mathf.Sin(r1), 0) * Radius);
            }
        }
    }
}
