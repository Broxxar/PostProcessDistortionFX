using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

/// <summary>
/// The serializable data representation of our custom Post Process effect.
/// Note that for serialization reasons the class name must match the file name.
/// </summary>
[Serializable]
[PostProcess(typeof(DistortionRenderer), PostProcessEvent.BeforeStack, "Custom/Distortion")]
public class Distortion : PostProcessEffectSettings
{
    /// <summary>
    /// A global scale on the magnitude of distortion effects.
    /// </summary>
    [Range(0f, 1.0f), Tooltip("The magnitude in texels of distortion fx.")]
    public FloatParameter Magnitude = new FloatParameter { value = 1.0f };

    /// <summary>
    /// A down scale factor applied to the distortion texture. Increasing this value results in 
    /// a smaller RenderTexture being used, saving on fill-rate.
    /// </summary>
    [Range(0, 4), Tooltip("The down-scale factor to apply to the generated texture.")]
    public IntParameter DownScaleFactor = new IntParameter { value = 0 };

    /// <summary>
    /// Toggles the debug view to show the distortion effects in the world as color values.
    /// </summary>
    [Tooltip("Displays the Distortion Effects in debug view.")]
    public BoolParameter DebugView = new BoolParameter { value = false };
}

/// <summary>
/// The renderer for the custom Distortion Post Process Effect.
/// </summary>
public class DistortionRenderer : PostProcessEffectRenderer<Distortion>
{
    /// <summary>
    /// Cached PropertyToID lookup for the shader uniform variable named "_GlobalDistortionTex".
    /// </summary>
    private int _globalDistortionTexID;

    /// <summary>
    /// Cached reference to the shader containing our custom post process.
    /// </summary>
    private Shader _distortionShader;

    /// <summary>
    /// Overridden to indicate our effect requires the camera depth texture.
    /// </summary>
    public override DepthTextureMode GetCameraFlags()
    {
        return DepthTextureMode.Depth;
    }

    /// <summary>
    /// Caches the shader property ID when the effect is initialized.
    /// </summary>
    public override void Init()
    {
        _globalDistortionTexID = Shader.PropertyToID("_GlobalDistortionTex");
        _distortionShader = Shader.Find("Hidden/Custom/Distortion");
        base.Init();
    }

    /// <summary>
    /// Renders the effect by targeting a temporary texture to render all registered distortion
    /// effects into, then by performing a full screen pass which offsets UVs by the float values
    /// in the temporary texture.
    /// </summary>
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(_distortionShader);
        sheet.properties.SetFloat("_Magnitude", settings.Magnitude);

        if (!settings.DebugView)
        {
            context.command.GetTemporaryRT(_globalDistortionTexID,
                context.camera.pixelWidth >> settings.DownScaleFactor,
                context.camera.pixelHeight >> settings.DownScaleFactor,
                0, FilterMode.Bilinear, RenderTextureFormat.RGFloat);
            context.command.SetRenderTarget(_globalDistortionTexID);
            context.command.ClearRenderTarget(false, true, Color.clear);
        }

        DistortionManager.Instance.PopulateCommandBuffer(context.command);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
