/*

    Copyright (c) 2024 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEngine;
using Highrise.Client;

namespace Highrise.Lua.Generated
{
    [AddComponentMenu("Lua/AnchorOld")]
    [LuaBehaviourScript(s_scriptGUID)]
    public class AnchorOld : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "37da264668ff1674b8a83b35b8b1b878";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public System.String m_animation = "sit";
        [SerializeField] public UnityEngine.Transform m_characterTransform = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_animation),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_characterTransform),
            };
        }
    }
}

#endif
