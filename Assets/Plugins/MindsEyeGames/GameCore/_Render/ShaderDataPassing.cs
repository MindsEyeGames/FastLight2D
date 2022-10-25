using System;
using UnityEngine;

namespace MEG
{
    /// <summary>
    /// Provides utility functions to allow CPU code to consistently
    /// match shader behavior when packing values for GPU computation.
    /// </summary>
    public class ShaderDataPassing
    {
        public static Color FloatToColor(float f)
        {
            float r = f % 1;
            float g = (f * 255) % 1;
            float b = (f * 255 * 255) % 1;
            float a = (f * 255 * 255 * 255) % 1;
            return new Color(
                r - (g / 255f),
                g - (b / 255f),
                b - (a / 255f),
                a);
        }

        public static Color Int32ToColor(int i)
        {
            byte[] bytes = BitConverter.GetBytes(i);
            return new Color32(bytes[0], bytes[1], bytes[2], bytes[3]);
        }
    }
}