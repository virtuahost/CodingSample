using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class LightSwitch : MonoBehaviour {

	public Light mMLight;

	private Light[] lights;
	private bool[] lightState;

	// Use this for initialization
	void Start () {
		findControllableLights ();
	}
	
	// Update is called once per frame
	void Update () {
	
	}
	
	void OnPreCull ()
	{
		mMLight.enabled = true;
		lightState = new bool[lights.Length]; 
		for (int i = 0; i < lights.Length; i++) {
			if(lights[i] != null){
				lightState[i] = lights[i].enabled;
				lights[i].enabled = false;
			}
		}
	}

	void OnPostRender ()
	{
		mMLight.enabled = false;
		for (int i = 0; i < lights.Length; i++) {
			if(lights[i] != null){
				lights[i].enabled = lightState[i];
			}
		}
	}

	private void findControllableLights(){
		List<Light> temp = new List<Light> ();
		Light[] all = (Light[])GameObject.FindObjectsOfType(typeof(Light));
		for (int i = 0; i < all.Length; i++) {
			if(all[i].gameObject.name != "MiniMapLight"){
				temp.Add (all[i]);
			}
		}
		
		lights = temp.ToArray ();
		
	}

}
