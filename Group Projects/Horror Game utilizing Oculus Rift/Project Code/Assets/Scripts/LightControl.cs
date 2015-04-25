using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class LightControl : MonoBehaviour {

	// controllable lights
	private Light[] lights;

	// flag to use random lights
	public bool randomLights;

	// time between light changes
	[Range(0,1)]
	public float delay;

	// Use this for initialization
	void Start () {
		randomLights = false;
		findControllableLights ();
	}

	public void setRandomLights(bool randomLightsOn){
		bool currentFlag = randomLights;
		randomLights = randomLightsOn;
		if(!currentFlag && randomLights)
			StartCoroutine (randomLightRoutine());
	}

	public bool getRandomLights(){
		return randomLights;
	}

	private IEnumerator randomLightRoutine() {
		for (int i = 0; i < lights.Length; i++) {
			FlickerLight flicker = lights[i].gameObject.GetComponent<FlickerLight>();
			flicker.flickerRate = Random.Range (5.0f,200.0f);
			flicker.randomness = Random.Range (0.0f,100.0f);
		}
		yield return new WaitForSeconds (delay);
		if(randomLights)
			StartCoroutine (randomLightRoutine());
	}

	private void findControllableLights(){
		List<Light> temp = new List<Light> ();
		Light[] all = (Light[])GameObject.FindObjectsOfType(typeof(Light));
		for (int i = 0; i < all.Length; i++) {
			if(all[i].gameObject.tag == "Controllable"){
				temp.Add (all[i]);
			}
		}

		lights = temp.ToArray ();

	}

}
