using UnityEngine;
using System.Collections;

public class GravityShotBehaviour : MonoBehaviour {
	
	public float bulletSpeed;
	
	private float currentSpeed;

	public GameObject player;

	private float startTime;

	public float destroyTime = 1f;
	
	// Use this for initialization
	void Start () {
		firBullet();
		player = GameObject.Find("cameraPoint");
		startTime = Time.time;
	}
	
	// Update is called once per frame
	void Update () {
		transform.position += transform.forward * currentSpeed * Time.deltaTime;
//		Debug.Log ("Hello: " + (Time.time - startTime));
		if ((Time.time - startTime) > destroyTime) {
			Destroy(this.gameObject);
				}
	}
	
	public void firBullet(){
		currentSpeed = bulletSpeed;
	}
}
