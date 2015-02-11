using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class GameController : MonoBehaviour {

	// Flag for pausing win/lose state etc
	private bool running;

	// Reference for current sanity level
	private SanitySetterScript sanity;

	// Player reference
	private GameObject player;

	// Win/Loss flags
	private bool lose,win;

	// start values for ambient light fade
	private Color lightStart;

	// start values for flashlight fade
	private float flashlightStart;

	// flashlight light reference
	Light flashlight;

	// Fade length
	public float fadeTime;

	// Text Mesh for win/loss messages
	TextMesh winLoseText;

	// Color for win/lose message
	private Color winColor;
	private Color loseColor;

	// Lights in the scene (used for fade)
	private Light[] lights;
	// Lights start values
	private float[] lightStarts;

	// Use this for initialization
	void Start () {
		running = true;
		win = false;
		lose = false;
		sanity = GameObject.Find ("sanitySetter").GetComponent<SanitySetterScript> ();
		player = GameObject.Find ("player");
		flashlight = GameObject.Find ("flashlight").light;
		winLoseText = GameObject.Find ("WinLoseText").GetComponent<TextMesh> ();
		winColor = new Color (0,180,0,255);
		loseColor = new Color (128,0,0,255);
		findLights ();
	}

	// every frame
	void Update(){

		if(sanity.sanity < 1 && running){
			triggerLoss();
		}

		if (Input.GetKeyDown (KeyCode.L)) {
			//findLights();
			sanity.sanity = 0;
		}
		if (Input.GetKeyDown (KeyCode.K)) {
			triggerWin ();
		}

	}

	void FixedUpdate(){
		// game is paused
		if(!running){
			// lose state
			if(lose){

				Color currentAmbient = RenderSettings.ambientLight;
				currentAmbient.r -= (lightStart.r*(1.0f/fadeTime))*Time.deltaTime;
				currentAmbient.g -= (lightStart.g*(1.0f/fadeTime))*Time.deltaTime;
				currentAmbient.b -= (lightStart.b*(1.0f/fadeTime))*Time.deltaTime;
				float currentFlash = flashlight.intensity;
				currentFlash -= flashlightStart*(1.0f/fadeTime)*Time.deltaTime;

				RenderSettings.ambientLight = currentAmbient;
				flashlight.intensity = currentFlash;
				
				loseColor.a += (1.0f/fadeTime/2.0f) * Time.deltaTime;
				winLoseText.color = loseColor;

				for(int i = 0; i<lights.Length; i++){
					if(lights[i] != null)
						lights[i].intensity -= (lightStarts[i]*(1.0f/fadeTime))*Time.deltaTime;
				}

			}
			// win state
			else if(win){

				Color currentAmbient = RenderSettings.ambientLight;
				currentAmbient.r -= (lightStart.r*(1.0f/fadeTime))*Time.deltaTime;
				currentAmbient.g -= (lightStart.g*(1.0f/fadeTime))*Time.deltaTime;
				currentAmbient.b -= (lightStart.b*(1.0f/fadeTime))*Time.deltaTime;
				float currentFlash = flashlight.intensity;
				currentFlash -= flashlightStart*(1.0f/fadeTime)*Time.deltaTime;
				
				RenderSettings.ambientLight = currentAmbient;
				flashlight.intensity = currentFlash;
				
				winColor.a += (1.0f/fadeTime/2.0f) * Time.deltaTime;
				winLoseText.color = winColor;

				for(int i = 0; i<lights.Length; i++){
					if(lights[i] != null)
						lights[i].intensity -= (lightStarts[i]*(1.0f/fadeTime))*Time.deltaTime;
				}

			}
		}
	}

	// get running states
	public bool isRunning(){
		return running;
	}

	// set running state
	private void setRunning(bool isRunning){
		this.running = isRunning;
	}

	// pause game
	public void pause(){
		setRunning (false);
	}

	// resume game
	public void play(){
		setRunning (true);
	}

	// when the player's sanity reaches 0
	private void triggerLoss(){
		setRunning (false);
		sanity.flickerControl = false;
		lose = true;
		lightStart = RenderSettings.ambientLight;
		flashlightStart = flashlight.intensity;
		winLoseText.text = "You Have Been Lost\nTo The Nightmare";
		loseColor.a = 0;
		winLoseText.color = loseColor;
	}

	public void triggerWin(){
		setRunning (false);
		sanity.flickerControl = false;
		win = true;
		lightStart = RenderSettings.ambientLight;
		flashlightStart = flashlight.intensity;
		winLoseText.text = "You Have Found Your Way\nBack To Reality";
		winColor.a = 0;
		winLoseText.color = winColor;
	}

	// Get the lights in the scene
	private void findLights(){
		Light[] temp = (Light[])GameObject.FindObjectsOfType(typeof(Light));
		List<Light> output = new List<Light>();
		for (int i = 0; i<temp.Length; i++) {
			if(!temp[i].gameObject.name.Equals("flashlight")){
				output.Add (temp[i]);
			}
		}
		lights = output.ToArray ();
		lightStarts = new float[lights.Length];
		for(int i=0; i<lights.Length;i++){
			lightStarts[i] = lights[i].intensity;
		}

	}

}
