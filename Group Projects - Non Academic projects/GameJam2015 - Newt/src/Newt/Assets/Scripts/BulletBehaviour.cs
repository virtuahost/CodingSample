using UnityEngine;
using System.Collections;

public class BulletBehaviour : MonoBehaviour {

	public float bulletSpeed;

	private float currentSpeed;

	public GameObject player;

	// Use this for initialization
	void Start () {
		firBullet();
		player = GameObject.Find("cameraPoint");
	
	}
	
	// Update is called once per frame
	void Update () {
		transform.position += transform.forward * currentSpeed * Time.deltaTime;	
	}

	public void firBullet(){
		currentSpeed = bulletSpeed;
	}

	void OnTriggerEnter(Collider hit){
//		Debug.Log ("Collision");
		if(hit.gameObject.tag == "Player"){
//			Debug.Log ("Collision happn");
			player.GetComponent<PlayerController>().killPlayer();
		}
	}
}
