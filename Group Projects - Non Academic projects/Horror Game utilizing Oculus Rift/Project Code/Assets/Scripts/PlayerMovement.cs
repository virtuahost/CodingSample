using UnityEngine;
using System.Collections;

public class PlayerMovement : MonoBehaviour {
	
	// Speed/Acc settings
	public float maxSpeed;
	public float sprintSpeed;
	public float dodgeSpeed;
	public float acceleration;
	public float deceleration;
	public float gravity;	
	public GameObject monster;
	public GameObject skeleton1;
	public GameObject skeleton2;
	public GameObject skeleton3;
	public GameObject pumpkin;

	// Mouse Sensitivity
	[Range(0,10)]
	public float mouseSensitivity;

	// strafe acceleration
	private float horizontalAcceleration;

	// Usable maxspeed variable (changes depending on sprint)
	private float currentMaxSpeed;

	// Stamina for sprint
	public float stamina;
	public float staminaRegenRate;
	public float staminaUseRate;
	private float staminaX, staminaY, staminaHeight, staminaWidth;

	// Spray Prefab
	public GameObject sprayPrefab;

	// Player Forward Direction
	public Transform forwardTransform;

	// Camera Controller transform and script
	public Transform cameraControllerTransform;
	public OVRCameraController cameraController;
	public Transform leftEye;

	// Character Controller
	public CharacterController controller;

	// Flag for first initialization
	private bool initialized = false;

	// Sanity Script
	private SanitySetterScript sanity;

	// Movement/Animation values
	private Vector3 nextMovement;
	private Vector3 prevLocation;
	private float nextRot;
	private float prevRot;

	// Reference to game controller
	private GameController game;

	// Inventory
	Inventory inventory;
	
	//Heal for key
	private float totalHeal=0;
	private bool healed=false;
	private float healAmount=70;


	// Use this for initialization
	void Start () {
		horizontalAcceleration = 10;
		prevLocation = transform.position;
		sanity = GameObject.Find ("sanitySetter").GetComponent<SanitySetterScript> ();
		game = GameObject.Find ("GameController").GetComponent<GameController> ();
		inventory = gameObject.GetComponent<Inventory> ();
		stamina = 100.0f;

	}
	
	// Update is called once per frame
	void Update () {

		if (!initialized) {
			initialized = true;
			OVRCamera.ResetCameraPositionOrientation(Vector3.one, Vector3.zero, Vector3.up, Vector3.zero);
		}

		if (Input.GetButtonDown ("Fire1")) {
			placeSpray ();
		}
		if (game.isRunning()) {
			//animatePlayerLate();
			calculateMovement ();
			movePlayer ();
			//Before Mecanim
			//animatePlayerEarly ();
		}
		
	

	}
	
	// Physics Update

	// Final Update called
	void LateUpdate() {
			//After Mecanim
			

	}
	
	// Calculate the next movement with physics simulation
	private void calculateMovement(){

		// Set max speed based on sprint key and use/regenerate stamina
		if(Input.GetButton ("Sprint")) {
			if(stamina > 0.0f){
				currentMaxSpeed = sprintSpeed;
				stamina -= staminaUseRate * Time.deltaTime;
				if(stamina < 0.0f) stamina = 0.0f;
			}
			else{
				currentMaxSpeed = maxSpeed;
			}
		}
		else {
			currentMaxSpeed = maxSpeed;
			stamina += staminaRegenRate * Time.deltaTime;
			if(stamina > 100.0f) stamina = 100.0f;
		}

		//Debug.Log (stamina);

		// Set current player velocity (vertical movement handled seperately)
		nextMovement = controller.velocity;
		nextMovement.y = 0.0f;

		// Flags for movement
		bool moveV = false, moveH = false;

		// Forward/Backward Movement
		if (Input.GetButton ("Vertical") && controller.isGrounded) {
			moveV = true;
			nextMovement += Input.GetAxis("Vertical") * forwardTransform.forward.normalized * acceleration * Time.deltaTime;
		}

		// Strafing
		if (Input.GetButton ("Horizontal") && controller.isGrounded) {
			moveH = true;
			nextMovement += Input.GetAxis("Horizontal") * forwardTransform.right.normalized * horizontalAcceleration * Time.deltaTime;
		}

		// Mouse Rotation
		prevRot = nextRot;
		nextRot = Input.GetAxis ("Mouse X") * mouseSensitivity;

		// Deceleration
		if ((!moveV && !moveH && controller.isGrounded) || !controller.isGrounded) {
			if(controller.velocity.magnitude < .5f)
				nextMovement = Vector3.zero;
			else
				nextMovement -= controller.velocity.normalized * deceleration * Time.deltaTime;
		}

		// Keep Movement under max speed
		if(nextMovement.magnitude > currentMaxSpeed && controller.isGrounded){
			nextMovement *= (currentMaxSpeed/nextMovement.magnitude);
		}

		// Dodge
		if (moveH && !moveV && Input.GetButtonDown ("Sprint")) {
			//Debug.Log("Dodge");
			float dir = Input.GetAxis("Horizontal").CompareTo(0);
			nextMovement = forwardTransform.right.normalized * dir * dodgeSpeed;
			nextMovement.y = 3.0f;
		}

	}
	
	// Apply gravity and attempt movement with the player controller
	private void movePlayer(){
		nextMovement.y -= gravity * Time.deltaTime;
		prevLocation = transform.position;
		controller.Move (nextMovement * Time.deltaTime);
		transform.Rotate (0, nextRot, 0, Space.World);
	}
	
	// Before Mecanim
	private void animatePlayerEarly(){
		
	}
	
	// After Mecanim
	private void animatePlayerLate(){
		
	}

	// Triggers
	void OnTriggerEnter(Collider trigger){

		// Alpha Sanity Checkpoints
		if (trigger.tag == "SanityCheckpoint") {
			SanityCheckpoint cp = trigger.GetComponent<SanityCheckpoint>();
			if(sanity != null && cp != null){
				sanity.sanity = cp.sanity;
			}
		}

		// Escape (win state)
		if (trigger.tag == "Escape") {
			game.triggerWin();
		}

		// Pickup
		if (trigger.tag == "PickUp") {
			PickUp p = trigger.gameObject.GetComponent<PickUp>();
			//Debug.Log("Add:" + p.id);
			inventory.addItem(p.id);
			Destroy(trigger.gameObject, 0.1f);
			StartCoroutine("healPlayer");
//			monster.SetActive(true);
//			monster.audio.Play();
//			skeleton1.SetActive(true);
//			skeleton2.SetActive(true);
//			skeleton3.SetActive(true);
//			skeleton1.animation.Play("waitingforbattle");
//			skeleton1.audio.Play();
//			skeleton2.animation.Play("attack");
//			skeleton2.audio.Play();
//			skeleton3.animation.Play("dance");
//			skeleton3.audio.Play();
//			try{
//				pumpkin.SetActive(false);
//			}
//			catch(MissingReferenceException ex)
//			{
//
//			}
//			flashLight.enabled = false;
		}

	}

	private void placeSpray() {

		//Debug.Log("spraying");

		RaycastHit hit;
		if(Physics.Raycast (leftEye.position, leftEye.forward, out hit,2.0f)){
			//Debug.Log ("Hit Something");
			if(hit.transform.gameObject.tag == "wall"){
				//Debug.Log ("wall hit");
				Vector3 newLocation = hit.point + hit.normal * .001f;
				GameObject spray = GameObject.Instantiate(sprayPrefab,newLocation,Quaternion.LookRotation(hit.normal*-1)) as GameObject;
				spray.transform.parent = hit.transform;
			}
		}

	}
	
	IEnumerator healPlayer()
	{
		while(!healed)
		{
			sanity.sanity+=5*Time.deltaTime;
			totalHeal+=5*Time.deltaTime;
			Debug.Log("healing!!!");
			if(totalHeal > healAmount)
			{
				healed=true;
				Debug.Log ("healed!!");
			}
			yield return null;
		}
		
	}
	
}
