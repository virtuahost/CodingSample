using UnityEngine;
using System.Collections;

public class LavaBehaviour : MonoBehaviour {


	public GameObject _player;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void OnTriggerEnter(Collider hit){
		if(hit.gameObject.tag == "Player"){
			_player.GetComponent<PlayerController>().killPlayer();
		}
	}
}
