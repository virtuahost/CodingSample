using UnityEngine;
using System.Collections;

[RequireComponent (typeof (Light))]
public class FlickerLight : MonoBehaviour {

	// Average Flicker Rate
	[Range(5,200)]
	public float flickerRate;

	// Random Range (Percentage of flickerRate)
	[Range(0,100)]
	public float randomness;

	// Minimum Intensity for fade
	public float minIntensity = 0.0f;
	private float maxIntensity;
	private float intensityCeiling;
	private float dir = -1.0f;

	// Controllable from the light control
	public bool controllable;

	public bool flickering;

	private SanitySetterScript sanity;

	void Awake(){
		if(controllable)
			gameObject.tag = "Controllable";
		sanity = GameObject.Find ("sanitySetter").GetComponent<SanitySetterScript> ();
		intensityCeiling = 5.0f;
		maxIntensity = 5.0f;//light.intensity;
	}

	void Start(){
		//if(flickering)
			//StartCoroutine (flicker());
	}

	void FixedUpdate() {

		if (flickering) {

			light.intensity += (5.0f) *Time.deltaTime*dir;

			if(light.intensity <= minIntensity){
				light.intensity = minIntensity;
				dir *= -1.0f;
			}
			else if(light.intensity >= maxIntensity) {
				light.intensity = maxIntensity;
				dir *= -1.0f;
			}

		}

		minIntensity = intensityCeiling/2.0f  * (sanity.sanity / 100.0f);
		maxIntensity = 2.5f + 2.5f * (sanity.sanity / 100.0f);

	}

	private IEnumerator flicker() {
		float delay = 1.0f / flickerRate;
		light.enabled = false;
		yield return new WaitForSeconds (Random.Range (delay - delay*(randomness/100.0f),delay + delay*(randomness/100.0f)));
		light.enabled = true;
		yield return new WaitForSeconds (Random.Range ((delay - delay*(randomness/100.0f)),(delay + delay*(randomness/100.0f))));
		if(flickering)
			StartCoroutine (flicker ());
	}

}