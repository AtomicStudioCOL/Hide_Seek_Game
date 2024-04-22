/*

    Copyright (c) 2024 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

using System;
using System.Linq;
using UnityEngine;
using UnityEditor;

namespace Highrise.Studio.Generated
{
    internal static class LuaMenuItems
    {
        private static Type s_luaScriptType;
        private static Type s_luaBehaviourType;

        private static void LoadScriptType()
        {
            var assembly = AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(a => a.GetName().Name == "com.pz.highrise.lua");
            if (assembly == null)
                return;

            s_luaScriptType = assembly.GetTypes().FirstOrDefault(t => t.Name == "LuaScript");
            if (s_luaScriptType == null)
                return;

            assembly = AppDomain.CurrentDomain.GetAssemblies().FirstOrDefault(a => a.GetName().Name == "com.pz.highrise.game.client");
            if (assembly == null)
                return;

            s_luaBehaviourType = assembly.GetTypes().FirstOrDefault(t => t.Name == "LuaBehaviour");
            if (s_luaBehaviourType == null)
                return;
        }

        private static void AddScript(string path)
        {
            var gameObjects = Selection.gameObjects;
            if (gameObjects.Length == 0)
                return;

            if (s_luaScriptType == null)
                LoadScriptType();

            if (s_luaScriptType == null || s_luaBehaviourType == null)
                return;

            var asset = AssetDatabase.LoadAssetAtPath(path, s_luaScriptType);
            if (asset == null)
                return;

            AddScript(gameObjects, asset);
        }

        private static void AddScript(GameObject[] parents, UnityEngine.Object script)
        {
            Undo.SetCurrentGroupName("Add Lua");

            foreach(var parent in parents)
            {
                var so = new SerializedObject(Undo.AddComponent(parent, s_luaBehaviourType));
                so.FindProperty("_script").objectReferenceValue = script;
                so.ApplyModifiedProperties();
            }

            Undo.RecordObjects(parents, "Add Lua");
        }

        [MenuItem("Component/Lua/Checking Player Hidden")]
        private static void AddComponent1() => AddScript("Assets/Scripts/CheckingPlayerHidden.lua");
        [MenuItem("Component/Lua/Detecting Collisions")]
        private static void AddComponent2() => AddScript("Assets/Scripts/DetectingCollisions.lua");
        [MenuItem("Component/Lua/Players In Scene")]
        private static void AddComponent3() => AddScript("Assets/Scripts/PlayersInScene.lua");
        [MenuItem("Component/Lua/Ray Cast Player Seek")]
        private static void AddComponent4() => AddScript("Assets/Scripts/RayCastPlayerSeek.lua");
        [MenuItem("Component/Lua/Selecting Obj Hide")]
        private static void AddComponent5() => AddScript("Assets/Scripts/SelectingObjHide.lua");
        [MenuItem("Component/Lua/Anchor Old")]
        private static void AddComponent6() => AddScript("Packages/com.pz.studio/Runtime/Lua/AnchorOld.lua");
        [MenuItem("Component/Lua/General Chat")]
        private static void AddComponent7() => AddScript("Packages/com.pz.studio/Runtime/Lua/GeneralChat.lua");
        [MenuItem("Component/Lua/Highrise Camera Controller")]
        private static void AddComponent8() => AddScript("Packages/com.pz.studio/Runtime/Lua/HighriseCameraController.lua");
        [MenuItem("Component/Lua/RTS Camera")]
        private static void AddComponent9() => AddScript("Packages/com.pz.studio/Runtime/Lua/RTSCamera.lua");
        [MenuItem("Component/Lua/Scene Loader")]
        private static void AddComponent10() => AddScript("Packages/com.pz.studio/Runtime/Lua/SceneLoader.lua");

    }
}

