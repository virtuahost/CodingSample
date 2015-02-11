using UnityEngine;
using System.Collections.Generic;
using System.Collections;

public class SanitySetterScript : MonoBehaviour {
	
	public GameObject[] c;
	public float sanity=100;
	public float sanityDegen;
	public float sanityRegen;
	//public GUITexture sanityBar;
	public bool flickerControl;
	public float delay;

	private Light[] lights;
	private BlurController leftBlurController;
	private BlurController rightBlurController;
//	private float initSanityWidth;
//	private float initSanityX;
//	private float initSanityY;
//	private float initSanityHeight;
	// Use this for initialization
	void Start () {
		findControllableLights ();
		if (flickerControl) {
			StartCoroutine (lightFlicker());
		}
		leftBlurController = GameObject.Find("CameraLeft").GetComponent<BlurController>();
		rightBlurController = GameObject.Find("CameraRight").GetComponent<BlurController>();
//		initSanityX = sanityBar.pixelInset.x;
//		initSanityY = sanityBar.pixelInset.y;
//		initSanityWidth = sanityBar.pixelInset.width;
//		initSanityHeight = sanityBar.pixelInset.height;
		c= GameObject.FindGameObjectsWithTag("collapsible");
	}
	
	// Update is called once per frame
	void Update () {
		foreach(GameObject corr in c)
			corr.GetComponent<ScaryCorridorBehaviour>().setSanity(sanity);
	//	sanityBar.pixelInset = new Rect(initSanityX, initSanityY, (sanity/100)*initSanityWidth, initSanityHeight);
		leftBlurController.sanity = sanity;
		rightBlurController.sanity = sanity;
		sanity+=(-sanityDegen + sanityRegen)*Time.deltaTime;
		
		sanity = Mathf.Clamp(sanity , 0, 100);
	
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

	private IEnumerator lightFlicker(){
		for (int i = 0; i < lights.Length; i++) {
			FlickerLight flicker = lights[i].gameObject.GetComponent<FlickerLight>();
			flicker.flickerRate = 30 - (sanity/100.0f) * 29.67f; //Random.Range (5.0f,200.0f);
			//flicker.randomness = 100.0f - sanity;//Random.Range (0.0f,100.0f);
		}
		yield return new WaitForSeconds (delay);
		if(flickerControl)
			StartCoroutine (lightFlicker());
	}
	
}
