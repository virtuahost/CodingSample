using UnityEngine;
using System.Collections;

public class PickUp : MonoBehaviour {

	// Use this for initialization
	public string itemName;

	public GameObject player;

	void OnTriggerEnter(Collider hit){
		if(hit.gameObject.tag == "Player"){
			player.GetComponent<Inventory>().addItem(itemName);
			Destroy(this.gameObject);

		}
	}
}
