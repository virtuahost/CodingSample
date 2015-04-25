using UnityEngine;
using System.Collections;

public class DirectFollow : MonoBehaviour {

	// Movement Speed
	public float moveSpeed;
	public float acceleration;

	// Player's transform to follow
	public Transform player;

	// Audio Object for pumpkin laughing
	public GameObject laughAudio;

	// Game Controller
	public GameController game;
	
	//Sanity Setter
	public GameObject sanitySetter;
	
	private BlurController leftBlur;
	private BlurController rightBlur;

	// Last Movement Vector so acecleration can be applied to it
	private Vector3 lastMovement = Vector3.zero;
	
	// Idle/Following
	private bool idle;
	
	// Use this for initialization
	void Start () {
		animation.Play ("Shake");
		laughAudio.audio.Play ();
		leftBlur = GameObject.Find("CameraLeft").GetComponent<BlurController>();
		rightBlur = GameObject.Find("CameraRight").GetComponent<BlurController>();
		idle = true;
	}
	
	// Update is called once per frame
	void Update () {

		if(game.isRunning()){
			
			if(idle){
				if((player.position - transform.position).magnitude < 20.0f)
					idle = false;
			}
			
			else{
				float scale = (transform.position - player.position).magnitude / 20.0f;
				Vector3 dir = ((player.position + player.forward*2.0f*scale) - transform.position).normalized;
				Vector3 acc = dir * acceleration * Time.deltaTime;
				Vector3 movementVector = lastMovement + acc;
				if(movementVector.magnitude > moveSpeed)
					movementVector *= (moveSpeed / movementVector.magnitude);
				transform.position += movementVector * Time.deltaTime;
				lastMovement = movementVector;
				transform.LookAt(transform.position + movementVector);
			}
		}

	}

	void LateUpdate() {

		if (game.isRunning ()) {
		}

	}
	
	void OnTriggerEnter(Collider c){
	Debug.Log(c.gameObject.name);
		if(c.gameObject.tag == "player"){
			sanitySetter.GetComponent<SanitySetterScript>().sanity-=20;
			leftBlur.oneShotPulse();
			rightBlur.oneShotPulse();
			Destroy(this.gameObject);
		}
	}


}
