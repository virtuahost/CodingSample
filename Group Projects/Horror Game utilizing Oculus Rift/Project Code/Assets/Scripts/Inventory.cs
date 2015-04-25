using UnityEngine;
using System.Collections;

public class Inventory : MonoBehaviour {

	public bool[] inventory;

	// Use this for initialization
	void Start () {
		inventory = new bool[10];
		for (int i =0; i<inventory.Length; i++) {
			inventory[i]  = false;
		}
	}

	// Add item based on id
	public bool addItem(int id){
		if (id < 0 || id >= inventory.Length) {
			return false;
		}
		inventory [id] = true;
		return true;
	}

	// Return true if the player has the item with the given id
	public bool hasItem(int id){
		if (id < 0 || id >= inventory.Length) {
			return false;
		}
		return inventory [id];
	}

}
