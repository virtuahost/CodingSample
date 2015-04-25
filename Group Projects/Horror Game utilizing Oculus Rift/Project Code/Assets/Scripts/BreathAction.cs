using UnityEngine;
using System.Collections;

public class BreathAction : MonoBehaviour {
	public float damageVal = 0.1f;
	private Transform player;
	private SanitySetterScript sanity;
	// Use this for initialization
	void Start () {
		player=GameObject.FindGameObjectWithTag("player").transform;
		sanity = GameObject.Find ("sanitySetter").GetComponent<SanitySetterScript> ();
	}
	
	// Update is called once per frame
	void Update () {
	
	}
	void OnTriggerEnter(Collider objColl){
		if (objColl.tag == "player") {
			if(this.particleSystem.isPlaying)sanity.sanity-=damageVal;			
		}
	}
	void OnTriggerStay(Collider objColl)
	{
		if (objColl.tag == "player") {
			if(this.particleSystem.isPlaying)sanity.sanity-=damageVal;			
		}
	}
}
