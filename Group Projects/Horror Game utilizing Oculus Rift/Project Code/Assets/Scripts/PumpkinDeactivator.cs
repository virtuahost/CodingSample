using UnityEngine;
using System.Collections;

public class PumpkinDeactivator : MonoBehaviour {
	
	
	public GameObject[] pumpkins;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}
	
	void OnTriggerEnter(Collider c)
	{
		if(c.gameObject.tag == "player")
		{
			foreach(GameObject pumpkin in pumpkins)
			{
				if(pumpkin != null)
					pumpkin.SetActive(false);
			}
		}
	}
}
