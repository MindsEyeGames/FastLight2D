using UnityEngine;

namespace MEG
{
    [System.Serializable]
    public class GlobalShaderTexture
    {
        [SerializeField] private string _key = "_TEXTURE";
        public string Key
        {
            get { return _key; }
            set
            {
                if (_key != value)
                {
                    bool shouldApply = IsApplied;
                    if (shouldApply) Revoke();
                    _key = value;
                    if (shouldApply) Apply();
                }
            }
        }

        [SerializeField] private Texture _texture;
        public Texture Texture
        {
            get { return _texture; }
            set
            {
                if (_texture != value)
                {
                    _texture = value;
                    if (IsApplied) Apply();
                }
            }
        }

        public bool IsApplied { get; private set; }

        public virtual void Apply()
        {
            IsApplied = true;
            Shader.SetGlobalTexture(Key, Texture);
        }

        public virtual void Revoke()
        {
            if (IsApplied)
            {
                Shader.SetGlobalTexture(Key, null);
                IsApplied = false;
            }
        }
    }

    [System.Serializable]
    public class GlobalShaderRenderTex
    {
        [SerializeField] private string _key = "_RENDER_TEX";
        public string Key
        {
            get { return _key; }
            set
            {
                if (_key != value)
                {
                    bool shouldApply = IsApplied;
                    if (shouldApply) Revoke();
                    _key = value;
                    if (shouldApply) Apply();
                }
            }
        }

        [SerializeField] private RenderTexture _texture;
        public RenderTexture Texture
        {
            get { return _texture; }
            set
            {
                if (_texture != value)
                {
                    _texture = value;
                    if (IsApplied) Apply();
                }
            }
        }

        public bool IsApplied { get; private set; }

        public virtual void Apply()
        {
            IsApplied = true;
            Shader.SetGlobalTexture(Key, Texture);
        }

        public virtual void Revoke()
        {
            if (IsApplied)
            {
                Shader.SetGlobalTexture(Key, null);
                IsApplied = false;
            }
        }
    }

    [System.Serializable]
    public class GlobalShaderColor
    {
        [SerializeField] private string _key = "_COLOR";
        public string Key
        {
            get { return _key; }
            set
            {
                if (_key != value)
                {
                    bool shouldApply = IsApplied;
                    if (shouldApply) Revoke();
                    _key = value;
                    if (shouldApply) Apply();
                }
            }
        }

        [SerializeField] private Color _color = new Color();
        public Color Color
        {
            get { return _color; }
            set
            {
                if (_color != value)
                {
                    _color = value;
                    if (IsApplied) Apply();
                }
            }
        }

        public Color ResetValue = new Color(0, 0, 0, 0);

        public bool IsApplied { get; private set; }

        public virtual void Apply()
        {
            IsApplied = true;
            Shader.SetGlobalColor(Key, Color);
        }

        public virtual void Revoke()
        {
            if (IsApplied)
            {
                Shader.SetGlobalColor(Key, ResetValue);
                IsApplied = false;
            }
        }
    }

    [System.Serializable]
    public class GlobalShaderV4
    {
        [SerializeField] private string _key = "_VECTOR4";
        public string Key
        {
            get { return _key; }
            set
            {
                if (_key != value)
                {
                    bool shouldApply = IsApplied;
                    if (shouldApply) Revoke();
                    _key = value;
                    if (shouldApply) Apply();
                }
            }
        }

        [SerializeField] private Vector4 _vector = new Vector4(0, 0, 1, 1);
        public Vector4 Vector
        {
            get { return _vector; }
            set
            {
                if (_vector != value)
                {
                    _vector = value;
                    if (IsApplied) Apply();
                }
            }
        }

        public Vector4 ResetValue = new Vector4(0, 0, 1, 1);

        public bool IsApplied { get; private set; }

        public virtual void Apply()
        {
            IsApplied = true;
            Shader.SetGlobalVector(Key, Vector);
        }

        public virtual void Revoke()
        {
            if (IsApplied)
            {
                Shader.SetGlobalVector(Key, ResetValue);
                IsApplied = false;
            }
        }
    }

    [System.Serializable]
    public class GlobalShaderFloat
    {
        [SerializeField] private string _key = "_FLOAT";
        public string Key
        {
            get { return _key; }
            set
            {
                if (_key != value)
                {
                    bool shouldApply = IsApplied;
                    if (shouldApply) Revoke();
                    _key = value;
                    if (shouldApply) Apply();
                }
            }
        }

        [SerializeField] private float _value = 1;
        public float Value
        {
            get { return _value; }
            set
            {
                if (_value != value)
                {
                    _value = value;
                    if (IsApplied) Apply();
                }
            }
        }

        public float ResetValue = 1;

        public bool IsApplied { get; private set; }

        public virtual void Apply()
        {
            IsApplied = true;
            Shader.SetGlobalFloat(Key, Value);
        }

        public virtual void Revoke()
        {
            if (IsApplied)
            {
                Shader.SetGlobalFloat(Key, ResetValue);
                IsApplied = false;
            }
        }
    }

    [System.Serializable]
    public class GlobalShaderInt
    {
        [SerializeField] private string _key = "_INT";
        public string Key
        {
            get { return _key; }
            set
            {
                if (_key != value)
                {
                    bool shouldApply = IsApplied;
                    if (shouldApply) Revoke();
                    _key = value;
                    if (shouldApply) Apply();
                }
            }
        }

        [SerializeField] private int _value = 1;
        public int Value
        {
            get { return _value; }
            set
            {
                if (_value != value)
                {
                    _value = value;
                    if (IsApplied) Apply();
                }
            }
        }

        public int ResetValue = 1;

        public bool IsApplied { get; private set; }

        public virtual void Apply()
        {
            IsApplied = true;
            Shader.SetGlobalInt(Key, Value);
        }

        public virtual void Revoke()
        {
            if (IsApplied)
            {
                Shader.SetGlobalInt(Key, ResetValue);
                IsApplied = false;
            }
        }
    }
}
