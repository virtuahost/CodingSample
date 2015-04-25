using UnityEngine;
using System.Collections;

public class TurretBehaviour : MonoBehaviour {
	
	public float fireDelay;
	public GameObject bullet;
	public Transform bulletSpawnPoint;
	public Transform player;

	public enum TurretState{
		Idle,
		Attacking
	}

	public TurretState _state;

	private AudioSource gunShot;


	private float lastFireTime;

	// Use this for initialization
	void Start () {
		_state = TurretState.Idle;
		gunShot = GetComponent<AudioSource>();
	
	}
	
	// Update is called once per frame
	void Update () {
		if(_state == TurretState.Attacking){
			transform.parent.LookAt(player.position);

			if(Time.time - lastFireTime > fireDelay){
				GameObject firedBullet = Instantiate(bullet, bulletSpawnPoint.position, bulletSpawnPoint.rotation) as GameObject;
				if(!gunShot.isPlaying){
					gunShot.Play();
				}
				lastFireTime = Time.time;
			}

			if(Input.GetKeyDown(KeyCode.Space)){
				_state = TurretState.Idle;
			}
		}
	
	}

	void OnTriggerEnter(Collider hit){
		if(hit.gameObject.tag == "Player"){
			if(gameObject.layer == 8){
				if(player.GetComponent<PlayerController>()._gravityState == PlayerController.GravityState.Roof){
					_state = TurretState.Attacking;
					lastFireTime = Time.time;
				}
			}
			if(gameObject.layer == 9){
				if(player.GetComponent<PlayerController>()._gravityState == PlayerController.GravityState.Floor){
					_state = TurretState.Attacking;
					lastFireTime = Time.time;
				}
			}
		}

	}

	void OnTriggerExit(Collider hit){
		if(hit.gameObject.tag == "Player"){
			_state = TurretState.Idle;;
		}
	}

	IEnumerator startFiring(){
		while(true){
			Debug.Log("instantiated");
			GameObject firedBullet = Instantiate(bullet, bulletSpawnPoint.position, bulletSpawnPoint.rotation) as GameObject;
			//yield return new WaitForSeconds(fireDelay);
			yield return new WaitForSeconds(3.0f);
		}
	}

}
