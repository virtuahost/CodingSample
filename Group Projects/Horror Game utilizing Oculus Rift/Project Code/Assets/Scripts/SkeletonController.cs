using UnityEngine;
using System.Collections;

public class SkeletonController : MonoBehaviour {
	public bool isStatic = false;
	public bool isUseFlameThrower = false;
	public bool isUseFlameOrbs = false;	
	public bool isFollowPlayer = false;
	public Transform player;
	public Transform throwPoint;
	public GameObject orbAttackAudio;
	public GameObject flameAttackAudio;
	public ParticleSystem flameParticle;
	public GameObject orbParticle;
	public float chkDist = 10f;
	public float throwForce;
	public float flameThrowerInterval;
	
	private SanitySetterScript sanity;
	private NavMeshAgent agent;
	public Animation startAnime;
	private GameController game;
	private float startTime = 0f;
	private float lastAttackTime = 0f;
	private bool inAttackRange = false;
	private bool inAttackSight = false;
	private float lastFlameTime;
	// Use this for initialization
	void Start () {
		game = GameObject.Find ("GameController").GetComponent<GameController> ();
		agent = GetComponent<NavMeshAgent> ();
		//startTime = Time.time; 
		//laughAudio.audio.Play ();
		//flameAttackAudio=transform.FindChild("FlameAudio").gameObject;
		//orbAttackAudio=transform.FindChild("OrbAudio").gameObject;
		player=GameObject.FindGameObjectWithTag("player").transform;
		sanity = GameObject.Find ("sanitySetter").GetComponent<SanitySetterScript> ();
		if(flameParticle.isPlaying)flameParticle.Stop();
		this.transform.LookAt(player.transform.position);
		lastFlameTime=Time.time;
	}
	
	// Update is called once per frame
	void Update () {
		if (game.isRunning ()) {
			
			float dist=(player.position - transform.position).magnitude;	
			if(inAttackRange && inAttackSight && dist < chkDist)
			{//Debug.Log("In Sght");
				//if(!isStatic)
				//{
					if(isFollowPlayer && this.animation.IsPlaying("run"))
					{
						agent.Stop(true);
						this.animation.Stop("run");
						//this.animation.Play("waitingforbattle");
					}
					if(dist<3 && isUseFlameThrower)
					{//Debug.Log("In Flamethrower");
						if(orbAttackAudio.audio.isPlaying)orbAttackAudio.audio.Stop();
						if(!flameParticle.isPlaying){flameParticle.Play();}	
						if(!flameAttackAudio.audio.isPlaying)flameAttackAudio.audio.Play();
						Vector3 lookAtVector = player.position - transform.position;
						Vector3 lookAtVectorNoY = new Vector3(lookAtVector.x, transform.position.y, lookAtVector.z);
						Vector3 lookAtVectorLerp = Vector3.RotateTowards(transform.forward, lookAtVectorNoY, 0.5f * Time.deltaTime, 0.0f);
						this.transform.rotation = Quaternion.LookRotation(lookAtVectorLerp);
					if(!this.animation.isPlaying)
						{						
						
							this.animation.Play("waitingforbattle");//this.animation.Play("idle");
						}
						/*else
						{
							this.animation.Stop();
							if(dist>2)this.transform.LookAt(player.transform.position);
							this.animation.Play("idle");
						}*/
					}
					else if(isUseFlameThrower && isStatic && !isUseFlameOrbs)
					{//Debug.Log("In Oh no");
						if(orbAttackAudio.audio.isPlaying)orbAttackAudio.audio.Stop();
						if(!flameParticle.isPlaying){
							if(Time.time - lastFlameTime > flameThrowerInterval){
								flameParticle.Play();
								lastFlameTime=Time.time;
							}
						}
						if(!flameAttackAudio.audio.isPlaying)flameAttackAudio.audio.Play();
						if(!this.animation.isPlaying)
						{						
							if(dist>2)this.transform.LookAt(player.transform.position);
							this.animation.Play("waitingforbattle");//this.animation.Play("idle");
						}
						/*else
						{
							this.animation.Stop();
							if(dist>2)this.transform.LookAt(player.transform.position);
							this.animation.Play("idle");
						}*/
					}
					else if(isUseFlameOrbs && Time.time - lastAttackTime > 2)
					{//Debug.Log("In FlameOrb");
						if(flameParticle.isPlaying)flameParticle.Stop();	
						if(flameAttackAudio.audio.isPlaying)flameAttackAudio.audio.Stop();
						if(!this.animation.isPlaying)
						{						
							lastAttackTime = Time.time;
							if(dist>1)this.transform.LookAt(new Vector3(player.position.x, transform.position.y, player.position.z));
							this.animation.Play("attack");	
						Vector3 direction = (player.transform.position + (player.GetComponent<CharacterController>().velocity * Random.Range(0,player.GetComponent<CharacterController>().velocity.magnitude))) - throwPoint.position;
							GameObject orb = Instantiate(orbParticle,throwPoint.position,Quaternion.identity) as GameObject;
							orb.rigidbody.AddForce(direction.normalized*throwForce);
						}
						/*else
						{
							if(this.animation.IsPlaying("idle"))
							{
								this.animation.Stop();
								if(dist>1)this.transform.LookAt(player.transform.position);
								this.animation.Play("attack");
							}
						}*/
						if(!orbAttackAudio.audio.isPlaying)orbAttackAudio.audio.Play();
					}
				/*}
				else
				{
					if(dist<3 && isUseFlameThrower)
					{//Debug.Log("In Flamethrower");
						if(orbAttackAudio.audio.isPlaying)orbAttackAudio.audio.Stop();
						if(!flameParticle.isPlaying){flameParticle.Play();}	
						if(!flameAttackAudio.audio.isPlaying)flameAttackAudio.audio.Play();						
					}
					else if(isUseFlameThrower && isStatic && !isUseFlameOrbs)
					{//Debug.Log("In Oh no");
						if(orbAttackAudio.audio.isPlaying)orbAttackAudio.audio.Stop();
						if(!flameParticle.isPlaying){flameParticle.Play();}
						if(!flameAttackAudio.audio.isPlaying)flameAttackAudio.audio.Play();						
					}
					else if(isUseFlameOrbs && Time.time - lastAttackTime > 2)
					{//Debug.Log("In FlameOrb");
						if(flameParticle.isPlaying)flameParticle.Stop();	
						if(flameAttackAudio.audio.isPlaying)flameAttackAudio.audio.Stop();
						lastAttackTime = Time.time;
						Vector3 direction = player.transform.position - throwPoint.position;
						GameObject orb = Instantiate(orbParticle,throwPoint.position,Quaternion.identity) as GameObject;
						orb.rigidbody.AddForce(direction.normalized*throwForce);
						if(!orbAttackAudio.audio.isPlaying)orbAttackAudio.audio.Play();
					}				
				}*/
			}
			else if(inAttackRange)
			{//Debug.Log("Should not be here");
				if(flameParticle.isPlaying)flameParticle.Stop();
				if(flameAttackAudio.audio.isPlaying)flameAttackAudio.audio.Stop();
				if(orbAttackAudio.audio.isPlaying)orbAttackAudio.audio.Stop();
				if(!isStatic)
				{
					if(isFollowPlayer)
					{
						if(!this.audio.isPlaying)this.audio.Play();
						Vector3 newVector = new Vector3 (player.position.x, this.transform.position.y, player.position.z);						
						if(!this.animation.isPlaying)
						{
							this.animation.Play("run");
							agent.SetDestination (newVector);
						}
					}
				}
				else
				{
					if(!this.animation.isPlaying)
					{						
						if(dist>1)this.transform.LookAt(new Vector3(player.position.x, transform.position.y, player.position.z));;
						//this.animation.Play("waitingforbattle");
					}
				}
			}
		}
	}
	void OnTriggerEnter(Collider objColl){
		if (objColl.tag == "player") {
			startTime = Time.time;
		}
	}
	void OnTriggerStay(Collider objColl)
	{
		if (objColl.tag == "player") {
						inAttackRange = true;
						inAttackSight = false;

						Vector3 direction = player.transform.position - transform.position;
						float angle = Vector3.Angle (direction, transform.forward);
						if (angle < 110f * 0.5f) {
								RaycastHit hit;
								if (Physics.Raycast (transform.position + transform.up*0.2f, direction.normalized, out hit, chkDist)) {
										//Debug.Log(hit.collider.gameObject.name);
										if (hit.collider.gameObject.CompareTag("player")) {
											inAttackSight = true;
										}
									}
						}
				}

	}
	void OnTriggerExit(Collider objColl){
		if (objColl.tag == "player") {
			inAttackRange = false;
			if(isFollowPlayer)
			{
				agent.Stop();
				this.animation.Stop("run");
				this.animation.Play("waitingforbattle");
			}
		}
	}
}

