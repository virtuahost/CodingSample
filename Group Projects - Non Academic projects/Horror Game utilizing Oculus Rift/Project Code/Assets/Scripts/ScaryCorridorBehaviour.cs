using UnityEngine;
using System.Collections;

public class ScaryCorridorBehaviour : MonoBehaviour {

	public float maxSanity = 100.0f;
	public float minSanity = 0.0f;
	public float wallSpeed;
	public GameObject roomTrigger;
	public GameObject monster;
	public GameObject pumpkin;
	public GameObject skeleton;
	
	private float currentSanity = 100.0f;
	private Transform leftWall;
	private Transform rightWall;
	private Transform soundRoom;
	private ParticleSystem leftWallParticles;
	private AudioSource leftWallAudio;
	private AudioSource rightWallAudio;
	private ParticleSystem rightWallParticles;
	private float initWallSeperation;
	private bool isRunning = false;
	private bool stopRunning=false;
	private bool playSound=false;
	private float soundPlayStart;
	private float createTImeStamp = 0f;
	private float SecondsUntilCreate = 20f;
	private GameObject player;
	private Vector3 leftFinal;
	private Vector3 rightFinal;
	// Use this for initialization
	void Start () {
		leftWall=transform.FindChild("leftWall");
		rightWall=transform.FindChild("rightWall");
		soundRoom=transform.FindChild("soundRoom");
		roomTrigger=soundRoom.FindChild("playerTrigger").gameObject;
		initWallSeperation=rightWall.localPosition.x - leftWall.localPosition.x;
		leftWallParticles=leftWall.FindChild("leftWallEmitter").particleSystem;
		rightWallParticles=rightWall.FindChild("rightWallEmitter").particleSystem;
		leftWallAudio=leftWall.FindChild("leftWallAudio").GetComponent<AudioSource>();
		rightWallAudio=rightWall.FindChild("rightWallAudio").GetComponent<AudioSource>();
		player = GameObject.FindWithTag ("playerForward").gameObject;	
		leftFinal=leftWall.localPosition;
		rightFinal=rightWall.localPosition;
		leftWallParticles.Stop();
		rightWallParticles.Stop();
		
	
	}
	
	// Update is called once per frame
	void FixedUpdate () {
		bool playerEntered=roomTrigger.GetComponent<PlayerCheckerScript>().isPlayerInside;
		playSound=leftWall.localPosition != leftFinal && rightWall.localPosition != rightFinal;
		if(leftWall.localPosition != leftFinal && rightWall.localPosition != rightFinal)
		{
			
			leftWall.localPosition = Vector3.MoveTowards(leftWall.localPosition, leftFinal, wallSpeed*Time.deltaTime);
			rightWall.localPosition = Vector3.MoveTowards(rightWall.localPosition, rightFinal, wallSpeed*Time.deltaTime);
			soundRoom.localScale = new Vector3((rightWall.localPosition.x - leftWall.localPosition.x)/initWallSeperation , 1, 1);
		}
		if(!playerEntered)
		{
			leftFinal=new Vector3(-initWallSeperation/2, 0, 0);
			rightFinal=new Vector3(initWallSeperation/2, 0, 0);
		}
		if(playSound){
			soundPlayStart=Time.time;
			if(!leftWallParticles.isPlaying){
				leftWallParticles.Play();
			}
			if(!rightWallParticles.isPlaying){
				rightWallParticles.Play();
			}
			if(!leftWallAudio.isPlaying){
				leftWallAudio.Play();
			}
			if(!rightWallAudio.isPlaying){
				rightWallAudio.Play();
			}
		}else{
			if(Time.time - soundPlayStart > 1)
			{
				if(leftWallParticles.isPlaying){
					leftWallParticles.Stop();
				}
				if(rightWallParticles.isPlaying){
					rightWallParticles.Stop();
				}
				if(leftWallAudio.isPlaying){
					leftWallAudio.Stop();
				}
				if(rightWallAudio.isPlaying){
					rightWallAudio.Stop();
				}
			}
		}
	
	}

	public void setSanity(float sanity){
		bool playerEntered=roomTrigger.GetComponent<PlayerCheckerScript>().isPlayerInside;
		if(playerEntered && Mathf.Abs(currentSanity - sanity) > 5){
			float seperation=Mathf.Clamp(sanity*initWallSeperation/(maxSanity-minSanity),2,initWallSeperation);		
			Vector3 leftInitial = leftWall.localPosition;
			Vector3 rightInitial = rightWall.localPosition;
			leftFinal = new Vector3(-seperation/2, 0, 0);

			
			rightFinal = new Vector3(seperation/2, 0, 0);
			currentSanity = sanity;

			
		}
		
	}
	
}
