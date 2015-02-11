using UnityEngine;
using System.Collections;

public class FlashlightControl : MonoBehaviour {

	// Battery Settings
	private float batteryLife = 100.0f;
	public float drainRate;
	public float rechargeRate;

	// Flashlight
	public Light flashLight;

	// Battery GUI Textures
	public GUITexture[] batteries;

	private Color high,med,low;
	private Color[] batColors;

	void Start(){
		high = new Color (23, 115, 2, 255);
		med = new Color (149, 157, 8, 255);
		low = new Color (108, 0, 12, 255);
		batColors = new Color[] {low,med,high,high};
		setColors (high);
	}

	// Update is called once per frame
	void Update () {

		if (flashLight.enabled) {
			batteryLife -= drainRate * Time.deltaTime;
			if(batteryLife <= 0.0f){
				batteryLife = 0.0f;
				flashLight.enabled = false;
			}
		}

		else{
			batteryLife += rechargeRate * Time.deltaTime;
			if(batteryLife > 100.0f)
				batteryLife = 100.0f;
		}

		if (Input.GetButtonDown ("Flashlight")) {
			if(flashLight.enabled)
				flashLight.enabled = false;
			else{
				if(batteryLife > 0.0f)
					flashLight.enabled = true;
			}
		}

		for (int i = 0; i < 4; i++) {

			if(batteryLife > 25*i){
				batteries[i].enabled = true;
				setColors(batColors[i]);
			}
			else
				batteries[i].enabled = false;

		}

		//Debug.Log (batteryLife);

	}

	private void setColors(Color color){
		for (int i = 0; i < 4; i++) {
			batteries[i].color = color;
		}
	}

}
