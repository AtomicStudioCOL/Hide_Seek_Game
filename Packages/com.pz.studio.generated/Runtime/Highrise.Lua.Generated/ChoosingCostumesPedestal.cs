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
    [AddComponentMenu("Lua/ChoosingCostumesPedestal")]
    [LuaBehaviourScript(s_scriptGUID)]
    public class ChoosingCostumesPedestal : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "f7a77d6936f68c4468a80b6b7c2e2a00";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_woodenCoffin01 = default;
        [SerializeField] public UnityEngine.GameObject m_pumpkin01 = default;
        [SerializeField] public UnityEngine.GameObject m_spookyTree01 = default;
        [SerializeField] public UnityEngine.GameObject m_bookMagical01 = default;
        [SerializeField] public UnityEngine.GameObject m_stumpPossesed01 = default;
        [SerializeField] public UnityEngine.GameObject m_witchHat01 = default;
        [SerializeField] public UnityEngine.GameObject m_woodenCoffin02 = default;
        [SerializeField] public UnityEngine.GameObject m_pumpkin02 = default;
        [SerializeField] public UnityEngine.GameObject m_spookyTree02 = default;
        [SerializeField] public UnityEngine.GameObject m_bookMagical02 = default;
        [SerializeField] public UnityEngine.GameObject m_stumpPossesed02 = default;
        [SerializeField] public UnityEngine.GameObject m_witchHat02 = default;
        [SerializeField] public UnityEngine.GameObject m_woodenCoffin03 = default;
        [SerializeField] public UnityEngine.GameObject m_pumpkin03 = default;
        [SerializeField] public UnityEngine.GameObject m_spookyTree03 = default;
        [SerializeField] public UnityEngine.GameObject m_bookMagical03 = default;
        [SerializeField] public UnityEngine.GameObject m_stumpPossesed03 = default;
        [SerializeField] public UnityEngine.GameObject m_witchHat03 = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_woodenCoffin01),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_pumpkin01),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_spookyTree01),
                CreateSerializedProperty(_script.GetPropertyAt(3), m_bookMagical01),
                CreateSerializedProperty(_script.GetPropertyAt(4), m_stumpPossesed01),
                CreateSerializedProperty(_script.GetPropertyAt(5), m_witchHat01),
                CreateSerializedProperty(_script.GetPropertyAt(6), m_woodenCoffin02),
                CreateSerializedProperty(_script.GetPropertyAt(7), m_pumpkin02),
                CreateSerializedProperty(_script.GetPropertyAt(8), m_spookyTree02),
                CreateSerializedProperty(_script.GetPropertyAt(9), m_bookMagical02),
                CreateSerializedProperty(_script.GetPropertyAt(10), m_stumpPossesed02),
                CreateSerializedProperty(_script.GetPropertyAt(11), m_witchHat02),
                CreateSerializedProperty(_script.GetPropertyAt(12), m_woodenCoffin03),
                CreateSerializedProperty(_script.GetPropertyAt(13), m_pumpkin03),
                CreateSerializedProperty(_script.GetPropertyAt(14), m_spookyTree03),
                CreateSerializedProperty(_script.GetPropertyAt(15), m_bookMagical03),
                CreateSerializedProperty(_script.GetPropertyAt(16), m_stumpPossesed03),
                CreateSerializedProperty(_script.GetPropertyAt(17), m_witchHat03),
            };
        }
    }
}

#endif
