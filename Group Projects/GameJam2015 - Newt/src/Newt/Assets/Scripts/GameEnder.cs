using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class GameEnder : MonoBehaviour {


	public GameObject player;
	public GameObject endMessage;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	void OnTriggerEnter(Collider hit){
		if(hit.gameObject.tag == "Player"){
			if(player.GetComponent<Inventory>().containsItems("key"))
				endMessage.GetComponent<Text>().text = "YOU WIN WOO HOO!";
		}
	}
}
