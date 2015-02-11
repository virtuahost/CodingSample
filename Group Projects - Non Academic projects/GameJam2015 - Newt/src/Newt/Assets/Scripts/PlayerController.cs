using UnityEngine;
using System.Collections;

public class PlayerController : MonoBehaviour {

	public enum PlayerState{
		Idle,
		Moving,
		Switching,
		Death,
		Dying,
		Picking,
		Shooting
	}

	public enum GravityState{
		Roof,
		Floor
	}
	//State variables
	public PlayerState _playerState;
	public GravityState _gravityState;

	//Transforms for player gravity stwitch
	public Transform playerOnRoofTransfrom;
	public Transform playerOnFloorTransform;

	public GameObject head; 



	//Rotation bitches
	private Quaternion floorCameraRotation;
	private Quaternion roofCameraRotation;
	private float finalPositionY;

	//Speeds 
	public float cameraRotateSpeed;
	public float playerJumpSpeed;
	public float playerSpeed;
	public float playerGravitySpeed;

	//Movement Stuff
	private LayerMask _layerMask;
	public LayerMask _layerMaskFloor;
	public LayerMask _layerMaskRoof;
	public float moveSpeed;
	private Vector3 targetPosition;
	private CharacterController controller;
	public Transform character;
	private Transform characterGeometry;
	public float flipDelay = 3.0f;
	private float flipStartTime;


	public GameObject newtage; 
	private Animator anim; 

	//Dying
	private float enterDeath;
	private float deathDelay = 1.0f;

	//Camera
	public Camera cullCamera;

	//Gravity Vector
	private Vector3 g;

	//Checkpoint variables
	public Vector3 checkpointPosition;
	public GameObject trigger;

	//Audio
	public AudioSource flipAudio;

	//Delay for bullets
	public float bulletDelay = 2.0f;
	private float startTime;
	public GameObject bullet;
	public Transform bulletSpawnPoint;

	// Use this for initialization
	void Start () {
		trigger = GameObject.FindGameObjectWithTag ("ChkPntState");
		checkpointPosition = trigger.GetComponent<CheckPointState>().lastPosition;
		_playerState = PlayerState.Moving;
		_gravityState = GravityState.Floor;
		characterGeometry = character.FindChild("characterGeometry");
		controller = character.GetComponent<CharacterController>();
		_layerMask = _layerMaskFloor;
		g = new Vector3(0, - 10 , 0);
		anim = newtage.GetComponent<Animator>();
        //Gravity flip floor and roof detector for variable height puzzle start
        RaycastHit hitUp;
        float scaleY = characterGeometry.transform.position.normalized.y * 1000 * (_gravityState == GravityState.Roof ? -1 : 1);
        Vector3 lnCastVector = new Vector3(characterGeometry.transform.position.x,scaleY, characterGeometry.transform.position.z);
        if (Physics.Linecast(characterGeometry.transform.position,lnCastVector,out hitUp,(_gravityState == GravityState.Roof ? _layerMaskFloor : _layerMaskRoof))){
            finalPositionY = hitUp.point.y;
        }
        //Gravity flip floor and roof detector for variable height puzzle end
	}
	
	// Update is called once per frame
	void Update () {
		bool switchStart = false;
		//Idle state: play idle animation and look at mouse
		if(_playerState == PlayerState.Idle){
			anim.SetBool("idle", true);

			if(_gravityState == GravityState.Floor)
				_layerMask = _layerMaskFloor;
			if(_gravityState == GravityState.Roof)
				_layerMask = _layerMaskRoof;

			RaycastHit hit;
			if (Physics.Raycast(cullCamera.ScreenPointToRay(Input.mousePosition), out hit, 1000, _layerMask)) {
				targetPosition = hit.point;
//				Debug.Log(_layerMask);
			}
			// characterGeometry.LookAt(targetPosition);
			Vector3 newTarget = new Vector3(targetPosition.x, characterGeometry.position.y, targetPosition.z);
			Vector3 lookVector = (newTarget-characterGeometry.position).normalized; 
			Vector3 lookVectorNoY = new Vector3(lookVector.x, 0, lookVector.z);
			characterGeometry.rotation = Quaternion.LookRotation(lookVectorNoY,character.up); 

			controller.Move(g*Time.deltaTime);

			//If player presses WSAD
			if(Input.GetAxis("Vertical") != 0 || Input.GetAxis("Horizontal")!= 0){
				_playerState = PlayerState.Moving;
			}

			//If player presses space switch state
			if(Input.GetKeyDown(KeyCode.Space) && (flipStartTime == 0 || Time.time - flipStartTime > flipDelay)){
				if(GetComponent<Inventory>().containsItems("gravityGun")){
					anim.SetTrigger("flail");
					_playerState = PlayerState.Switching;

					//Determine the culling mask
					if(_gravityState == GravityState.Floor){
						cullCamera.cullingMask = (1 << LayerMask.NameToLayer("Default")) | (1 << LayerMask.NameToLayer("TransparentFX")) 
							| (1 << LayerMask.NameToLayer("Ignore Raycast")) | (1 << LayerMask.NameToLayer("Water"))
								| (1 << LayerMask.NameToLayer("UI")) | (1 << LayerMask.NameToLayer("Roof"));

					}
					if(_gravityState == GravityState.Roof){
						cullCamera.cullingMask = (1 << LayerMask.NameToLayer("Default")) | (1 << LayerMask.NameToLayer("TransparentFX")) 
							| (1 << LayerMask.NameToLayer("Ignore Raycast")) | (1 << LayerMask.NameToLayer("Water"))
								| (1 << LayerMask.NameToLayer("UI")) | (1 << LayerMask.NameToLayer("Floor"));
					}
                    RaycastHit hitUp;
                    float scaleY = characterGeometry.transform.position.normalized.y * 1000 * (_gravityState == GravityState.Roof ? -1 : 1);
                    Vector3 lnCastVector = new Vector3(characterGeometry.transform.position.x,scaleY, characterGeometry.transform.position.z);
                    if (Physics.Linecast(characterGeometry.transform.position,lnCastVector,out hitUp,(_gravityState == GravityState.Roof ? _layerMaskFloor : _layerMaskRoof))){
                        finalPositionY = hitUp.point.y;
                    } 
					switchStart = true;
                    flipStartTime = Time.time;
				}
			}
			if(Input.GetMouseButtonDown(0) && (startTime == 0 || Time.time - startTime > bulletDelay)){
				if(GetComponent<Inventory>().containsItems("gravityGun"))
				{
					_playerState = PlayerState.Shooting;
				}
				startTime = Time.time;
			}

		}

		if(_playerState == PlayerState.Moving){
			anim.SetBool("idle", false);


			if (character.position.y < -1) {
				// to stop the camera stuff
			}
			
			if (character.position.y < -100) {
				_playerState = PlayerState.Death;
			}
			//Debug.Log("reached switching shift");

			if(_gravityState == GravityState.Floor)
				_layerMask = _layerMaskFloor;
			if(_gravityState == GravityState.Roof)
				_layerMask = _layerMaskRoof;
			RaycastHit hit;
			if (Physics.Raycast(cullCamera.ScreenPointToRay(Input.mousePosition), out hit, 1000, _layerMask)) {
				targetPosition = hit.point;
				//Debug.Log(targetPosition);
			}
			// characterGeometry.LookAt(targetPosition);
			Vector3 newTarget = new Vector3(targetPosition.x, characterGeometry.position.y, targetPosition.z);;
			Vector3 lookVector = (newTarget-characterGeometry.position).normalized; 
			Vector3 lookVectorNoY = new Vector3(lookVector.x, 0, lookVector.z);
			characterGeometry.rotation = Quaternion.LookRotation(lookVectorNoY,character.up); 

			Vector3 forward = characterGeometry.forward * Input.GetAxis("Vertical");
			//Vector3 forward = -1 * character.right * Input.GetAxis("Vertical");
			controller.Move(forward * playerSpeed * Time.deltaTime);
			//controller.Move(strafe * playerSpeed * Time.deltaTime);
			controller.Move(g*Time.deltaTime);

			transform.position = character.position;
			

			//For switching to idle check velocity
			if(controller.velocity.magnitude < 0.2){
				_playerState = PlayerState.Idle;
			}

			//Spacebar to switch to roof/floor
			if(Input.GetKeyDown(KeyCode.Space) && (flipStartTime == 0 || Time.time - flipStartTime > flipDelay)){
				if(GetComponent<Inventory>().containsItems("gravityGun"))
				{
					anim.SetTrigger("flail");
					_playerState = PlayerState.Switching;
					if(!flipAudio.isPlaying){
						flipAudio.Play();
					}
					
					//Determine the culling mask
					if(_gravityState == GravityState.Floor){
						cullCamera.cullingMask = (1 << LayerMask.NameToLayer("Default")) | (1 << LayerMask.NameToLayer("TransparentFX")) 
							| (1 << LayerMask.NameToLayer("Ignore Raycast")) | (1 << LayerMask.NameToLayer("Water"))
								| (1 << LayerMask.NameToLayer("UI")) | (1 << LayerMask.NameToLayer("Roof"));
					}
					if(_gravityState == GravityState.Roof){
						cullCamera.cullingMask = (1 << LayerMask.NameToLayer("Default")) | (1 << LayerMask.NameToLayer("TransparentFX")) 
							| (1 << LayerMask.NameToLayer("Ignore Raycast")) | (1 << LayerMask.NameToLayer("Water"))
								| (1 << LayerMask.NameToLayer("UI")) | (1 << LayerMask.NameToLayer("Floor"));
					}
                    RaycastHit hitUp;
                    float scaleY = characterGeometry.transform.position.normalized.y * 1000 * (_gravityState == GravityState.Roof ? -1 : 1);
                    Vector3 lnCastVector = new Vector3(characterGeometry.transform.position.x,scaleY, characterGeometry.transform.position.z);
                    if (Physics.Linecast(characterGeometry.transform.position,lnCastVector,out hitUp,(_gravityState == GravityState.Roof ? _layerMaskFloor : _layerMaskRoof))){
                        finalPositionY = hitUp.point.y;
                    }
					switchStart = true;
                    flipStartTime = Time.time;
				}
			}
			if(Input.GetMouseButtonDown(0) && (startTime == 0 || Time.time - startTime > bulletDelay)){
				if(GetComponent<Inventory>().containsItems("gravityGun"))
				{
					_playerState = PlayerState.Shooting;
				}
				startTime = Time.time;
			}
		}
		//Statw in which player switches gravity
		if(_playerState == PlayerState.Switching){
			Vector3 newTarget = new Vector3(targetPosition.x, characterGeometry.position.y, targetPosition.z);
			Vector3 lookVector = (newTarget-characterGeometry.position).normalized; 
			Vector3 lookVectorNoY = new Vector3(lookVector.x, 0, lookVector.z);
			characterGeometry.rotation = Quaternion.LookRotation(lookVectorNoY,character.up);  
			//Vector3 strafe = character.forward * Input.GetAxis("Horizontal");
			Vector3 forward = characterGeometry.forward * Input.GetAxis("Vertical");
			//strafe = strafe * playerGravitySpeed * Time.deltaTime;
			forward = forward * playerGravitySpeed * Time.deltaTime;


			if(_gravityState == GravityState.Floor){
				//Rotate camera around and flip the model
				//Debug.Log("Switching Original");
//				Move the camera to the roof
				Vector3 moveVector = transform.position + forward;
				Vector3 finalPosition = new Vector3(moveVector.x, finalPositionY, moveVector.z);
				transform.position = Vector3.MoveTowards(moveVector, finalPosition, playerJumpSpeed * Time.deltaTime);

				//Move the player to the roof
				character.position = Vector3.MoveTowards(moveVector, finalPosition, playerJumpSpeed * Time.deltaTime);

				//Rotate the camera to the roof
				transform.rotation = Quaternion.RotateTowards(transform.rotation, playerOnRoofTransfrom.rotation, cameraRotateSpeed * Time.deltaTime);

				//Rotate the player to the roof
				character.rotation = Quaternion.RotateTowards(transform.rotation, playerOnRoofTransfrom.rotation, cameraRotateSpeed * Time.deltaTime);



				//Switch the state
				if(transform.rotation == playerOnRoofTransfrom.rotation && transform.position == finalPosition){
					_gravityState = GravityState.Roof;
					_playerState = PlayerState.Idle;
					g *= -1;
				}
				if(Input.GetKeyDown(KeyCode.Space) && !switchStart && (flipStartTime == 0 || Time.time - flipStartTime > flipDelay)){
					_playerState = PlayerState.Switching;
					_gravityState = GravityState.Roof;
					g *= -1;
					//Determine the culling mask
					if(_gravityState == GravityState.Roof){
						cullCamera.cullingMask = (1 << LayerMask.NameToLayer("Default")) | (1 << LayerMask.NameToLayer("TransparentFX")) 
							| (1 << LayerMask.NameToLayer("Ignore Raycast")) | (1 << LayerMask.NameToLayer("Water"))
								| (1 << LayerMask.NameToLayer("UI")) | (1 << LayerMask.NameToLayer("Floor"));
					}
                    RaycastHit hitUp;
                    float scaleY = characterGeometry.transform.position.normalized.y * 1000 * (_gravityState == GravityState.Roof ? -1 : 1);
                    Vector3 lnCastVector = new Vector3(characterGeometry.transform.position.x,scaleY, characterGeometry.transform.position.z);
                    if (Physics.Linecast(characterGeometry.transform.position,lnCastVector,out hitUp,(_gravityState == GravityState.Roof ? _layerMaskFloor : _layerMaskRoof))){
                        finalPositionY = hitUp.point.y;
                    }
                    flipStartTime = Time.time;
				}

			}
			else if(_gravityState == GravityState.Roof){
				//Rotate camera around and flip the model
				//Move the player to the floor
				Vector3 moveVector = transform.position + forward;
				Vector3 finalPosition = new Vector3(moveVector.x, finalPositionY, moveVector.z);
				transform.position = Vector3.MoveTowards(moveVector, finalPosition, playerJumpSpeed * Time.deltaTime);

				//Move the player to the floor
				character.position = Vector3.MoveTowards(moveVector, finalPosition, playerJumpSpeed * Time.deltaTime);



				//Rotate the camera to the floor
				//cameraFocusTransform.rotation = Quaternion.RotateTowards(cameraFocusTransform.rotation, floorCameraRotation, cameraRotateSpeed * Time.deltaTime);

				//Rotate the camera to th floor
				Quaternion lookRotation = Quaternion.LookRotation(playerOnFloorTransform.forward, playerOnFloorTransform.up);
				transform.rotation = Quaternion.RotateTowards(transform.rotation, playerOnFloorTransform.rotation, cameraRotateSpeed * Time.deltaTime);

				//Rotate the player to the floor
				character.rotation = Quaternion.RotateTowards(transform.rotation, playerOnFloorTransform.rotation, cameraRotateSpeed * Time.deltaTime);


				//Switch the state
				if(transform.rotation == playerOnFloorTransform.rotation && transform.position == finalPosition){
					_gravityState = GravityState.Floor;
					_playerState = PlayerState.Idle;
					g *= -1;
				}
				
				if(Input.GetKeyDown(KeyCode.Space) && !switchStart && (flipStartTime == 0 || Time.time - flipStartTime > flipDelay)){
					_playerState = PlayerState.Switching;
					_layerMask = _layerMaskFloor;
					_gravityState = GravityState.Floor;
					g *= -1;
					//Determine the culling mask
					if(_gravityState == GravityState.Floor){
						cullCamera.cullingMask = (1 << LayerMask.NameToLayer("Default")) | (1 << LayerMask.NameToLayer("TransparentFX")) 
							| (1 << LayerMask.NameToLayer("Ignore Raycast")) | (1 << LayerMask.NameToLayer("Water"))
								| (1 << LayerMask.NameToLayer("UI")) | (1 << LayerMask.NameToLayer("Roof"));
					}
                    RaycastHit hitUp;
                    float scaleY = characterGeometry.transform.position.normalized.y * 1000 * (_gravityState == GravityState.Roof ? -1 : 1);
                    Vector3 lnCastVector = new Vector3(characterGeometry.transform.position.x,scaleY, characterGeometry.transform.position.z);
                    if (Physics.Linecast(characterGeometry.transform.position,lnCastVector,out hitUp,(_gravityState == GravityState.Roof ? _layerMaskFloor : _layerMaskRoof))){
                        finalPositionY = hitUp.point.y;
                    }
                    flipStartTime = Time.time;
				}
				
			}

		}
		if (_playerState == PlayerState.Death) {
			if(Time.time - enterDeath > deathDelay)
			{
			Vector3 offset = new Vector3 (0, 3, 0); 
			character.transform.position = checkpointPosition + offset;
			_playerState = PlayerState.Idle;
				enterDeath = Time.time;
			}

			
		}
		
		
		if (_playerState == PlayerState.Dying) {
			
		}

		if (_playerState == PlayerState.Shooting) {
			Vector3 lookVector = (targetPosition-characterGeometry.position).normalized; 
//			Debug.Log(bulletSpawnPoint.position);
			GameObject firedBullet = Instantiate(bullet, bulletSpawnPoint.position,bulletSpawnPoint.rotation) as GameObject;
			bullet.transform.LookAt(targetPosition);
			bullet.transform.position = lookVector;
			_playerState = PlayerState.Idle;
		}
	
	}

	public void killPlayer(){
		_playerState = PlayerState.Death;
		enterDeath = Time.time;
		anim.SetTrigger("die");
	}

}
