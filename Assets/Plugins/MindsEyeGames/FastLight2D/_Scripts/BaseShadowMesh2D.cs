using UnityEngine;

namespace MEG.FL2D
{
    /// <summary>
    /// There are lots of crazy shadow mesh possibilities (for example,
    /// bezier curve shadows are quite doable) but for this plugin only
    /// Collider2D-driven meshes are supplied.
    /// 
    /// If you want more, go for it! It should be pretty easy to make
    /// another shadow mesh variant (for example, ColliderShadowMesh2D).
    /// </summary>
    public abstract class BaseShadowMesh2D : MonoBehaviour
    {
        #region Core renderer controls
        [SerializeField] private MeshFilter _meshFilter;
        public MeshFilter MeshFilter
        {
            get { return _meshFilter; }
            set { _meshFilter = value; }
        }
        public Mesh Mesh { get; private set; }

        [SerializeField] private MeshRenderer _renderer;
        public MeshRenderer Renderer
        {
            get { return _renderer; }
            set { _renderer = value; }
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
            if (Properties != null)
            {
                Renderer.SetPropertyBlock(Properties);
            }
        }
        #endregion

        [Space(10)]

        #region Layer Mask
        [SerializeField] private LayerMask _layerMask = new LayerMask();
        public LayerMask LayerMask
        {
            get { return _layerMask; }
            set
            {
                if (_layerMask != value)
                {
                    _layerMask = value;
                    if (Properties != null)
                    {
                        PushLayerMaskProperties();
                        ApplyProperties();
                    }
                }
            }
        }

        [SerializeField] private string _layerMaskProperty = "_Layer_Mask";
        public string LayerMaskProperty
        {
            get { return _layerMaskProperty; }
            set
            {
                if (_layerMaskProperty != value)
                {
                    _layerMaskProperty = value;
                    if (Properties != null)
                    {
                        PushLayerMaskProperties();
                        ApplyProperties();
                    }
                }
            }
        }

        protected virtual void PushLayerMaskProperties()
        {
            Properties.SetColor(LayerMaskProperty, ShaderDataPassing.Int32ToColor(LayerMask.value));
            ApplyProperties();
        }
        #endregion

        [SerializeField] private bool _rebuildOnStart = true;
        public bool RebuildOnStart
        {
            get { return _rebuildOnStart; }
            set { _rebuildOnStart = value; }
        }

        public virtual void Start()
        {
            if (RebuildOnStart) Rebuild();
        }

        public virtual void Rebuild()
        {
            if (Properties == null) Properties = InitProperties();
            PushLayerMaskProperties();
            ApplyProperties();

            if (Mesh == null)
            {
                Mesh = new Mesh();
                Mesh.name = "ShadowMesh2D";
            }
            BuildMesh(Mesh);
            Mesh.UploadMeshData(false);
            MeshFilter.mesh = Mesh;
        }

        protected abstract void BuildMesh(Mesh m);

        public virtual void OnDestroy()
        {
            if (Mesh != null) Destroy(Mesh);
            Mesh = null;
        }
    }
}