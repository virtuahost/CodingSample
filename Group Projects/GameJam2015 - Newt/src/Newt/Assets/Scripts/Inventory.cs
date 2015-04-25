using UnityEngine;
using System.Collections;

public class Inventory : MonoBehaviour {

	public ArrayList inventoryItems = new ArrayList();

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}

	//Add Item
	public void addItem(string item){
		inventoryItems.Add(item);
//		Debug.Log("Picked up:"+item);
	}

	//Contains items?
	public bool containsItems(string item){
		return inventoryItems.Contains(item);
	}

}
