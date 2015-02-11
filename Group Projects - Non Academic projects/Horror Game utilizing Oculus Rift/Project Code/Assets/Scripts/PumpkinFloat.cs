using UnityEngine;
using System.Collections;

public class PumpkinFloat : MonoBehaviour {
	public float speed = 0.1f;
	public float SecondsUntilDestroy  = 30.0f;
	public Transform player;
	public GameObject laughAudio;
	public GameObject lightPumpkin;
	public GameObject pumpkin;
	private SanitySetterScript sanity;
	private float startTime = 0f;
	private NavMeshAgent agent;
	public Animation startAnime;
	private bool chaseMode = false; 
	private float maxIntensity = 0f;
	private float minIntensity = 0f;
	private float varIntensity = 0f;
	private float stateChngIntensity = 0f;
	private float varDist = 0.1f;
	private float maxDist = 0f;	
	private float offset = 0.01f;
	private bool playAnime = false;
	private bool stopFloat = false;
	private bool stopFloatMin = false;
	private GameController game;
	// Use this for initialization
	void Start () {
		game = GameObject.Find ("GameController").GetComponent<GameController> ();
		agent = GetComponent<NavMeshAgent> ();
		//startTime = Time.time; 
		//laughAudio.audio.Play ();
		laughAudio=transform.FindChild("LaughAudio").gameObject;
		player=GameObject.FindGameObjectWithTag("player").transform;
		maxIntensity = lightPumpkin.light.intensity;
		lightPumpkin.light.enabled = false;
		maxDist = this.transform.position.y;
		sanity = GameObject.Find ("sanitySetter").GetComponent<SanitySetterScript> ();
	}

	// Update is called once per frame
	void Update () {
		if(game.isRunning()){
		float angleDelta = 0f;
		
		// check if value not 0 and tease the rotation towards it using angleDelta
		if(this.transform.rotation.x > 0 ){
			angleDelta = -0.2f;
		} else if (this.transform.rotation.x < 0){
			angleDelta = 0.2f;
		}		
		float dist=(player.position - transform.position).magnitude;		
		if (dist >= 10.0f && chaseMode) {
			agent.Stop();
			chaseMode = false;
			laughAudio.audio.Stop();
		}
		if (sanity.sanity >= 80) {			
			stateChngIntensity = 0f;
			minIntensity = 0f;
			playAnime = false;
			chaseMode = false;	
			stopFloat = true;
			stopFloatMin = true;
				}
		else if (sanity.sanity < 80 && sanity.sanity > 60) {			
			stateChngIntensity = 1f;
			minIntensity = 0.5f;
			playAnime = false;
			chaseMode = false;
			stopFloat = true;
		} else if (sanity.sanity < 60 && sanity.sanity > 40) {			
			stateChngIntensity = 1.5f;
			minIntensity = 0.8f;
			playAnime = true;
			chaseMode = false;
			stopFloat = false;
		}
		else if(sanity.sanity <= 40)
		{
			stateChngIntensity = maxIntensity;
			minIntensity = 1f;
			if(dist <= 5.0f)
			{
				chaseMode = true;				
				playAnime = false;
				stopFloat = false;
			}
			else if(!chaseMode)
			{
				chaseMode = false;				
				playAnime = true;
				stopFloat = false;
			}
		}
		lightPumpkin.light.enabled = true;
		if(varIntensity >= stateChngIntensity)
		{
			varIntensity = minIntensity;
		}
		varIntensity += 0.2f;
		lightPumpkin.light.intensity = varIntensity;
		if (!stopFloat || stopFloatMin) {
						if (varDist >= player.position.y) {
								offset = -0.01f;
						} else if (varDist <= 0.0f) {
								offset = 0.01f;
						}
						varDist += offset;
						Vector3 newPostn = new Vector3 (this.transform.position.x, varDist, this.transform.position.z);
						float speed = ((newPostn - this.transform.position) / (5 * Time.deltaTime)).magnitude;
						this.transform.position = Vector3.MoveTowards (this.transform.position, newPostn, speed);
						if (chaseMode) {
								if (!laughAudio.audio.isPlaying) {
										laughAudio.audio.Play ();	
								}	
								Vector3 newVector = new Vector3 (player.position.x, this.transform.position.y, player.position.z);
								//agent.velocity = agent.velocity * sanity.sanity;
								agent.SetDestination (newVector);
						}
						if(stopFloatMin && varDist < 0.14f)
						{
							varDist = 0.1f;
							stopFloatMin = false;
						}
				}		
		if(playAnime)
		{
			this.animation.Play("Shake");
		}	
		//float dist=(player.position - transform.position).magnitude;		
		//float dist=(player.position - transform.position).magnitude;
		//if (Time.time - startTime >= SecondsUntilDestroy) {
		//	laughAudio.audio.Stop ();
		//	Destroy (this.gameObject);
		//		}
	}
	}
	void OnTriggerEnter(Collider objColl){
		if (objColl.tag == "player") {
						sanity.sanity-=5;
						Destroy (this.gameObject);
						
				}
	}	
}
