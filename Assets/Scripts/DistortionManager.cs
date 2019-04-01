using System.Collections.Generic;
using UnityEngine.Rendering;

/// <summary>
/// A manager that keeps tracks of objects that need to be rendered to the distortion buffer just
/// before rendering our custom after-stack Post Process effect.
/// </summary>
public class DistortionManager
{
    #region Singleton

    /// <summary>
    /// Singleton backing field.
    /// </summary>
    private static DistortionManager _instance;

    /// <summary>
    /// Singleton accessor. Replacing this for whatever ServiceLocator/Injection pattern your game
    /// uses would be a good idea when implementing a system like this!
    /// </summary>
    public static DistortionManager Instance
    {
        get
        {
            return _instance = _instance ?? new DistortionManager();
        }
    }

    #endregion

    /// <summary>
    /// The collection of distortion effects 
    /// </summary>
    private readonly List<DistortionEffect> _distortionEffects = new List<DistortionEffect>();

    /// <summary>
    /// Registers an effect with the manager.
    /// </summary>
    public void Register(DistortionEffect distortionEffect)
    {
        _distortionEffects.Add(distortionEffect);
    }

    /// <summary>
    /// Deregisters an effect from the manager.
    /// </summary>
    public void Deregister(DistortionEffect distortionEffect)
    {
        _distortionEffects.Remove(distortionEffect);
    }

    /// <summary>
    /// Adds the commands which draw the registered renderers to the target CommandBuffer.
    /// </summary>
    public void PopulateCommandBuffer(CommandBuffer commandBuffer)
    {
        for (int i = 0, len = _distortionEffects.Count; i < len; i++)
        {
            var effect = _distortionEffects[i];
            commandBuffer.DrawRenderer(effect.Renderer, effect.Material);
        }
    }
}
