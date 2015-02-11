using UnityEngine;
using System.Collections;

public class PlayerPusherScript : MonoBehaviour {
	
	CharacterController con;
	public float pushIntensity;
	// Use this for initialization
	void Start () {
		con=GameObject.Find("OVRPlayerController").GetComponent<CharacterController>();
	}
	
	// Update is called once per frame
	void Update () {
	
	}
	void OnTriggerStay(Collider c)
	{
		if(c.gameObject.tag=="player")
		{
			Vector3 moveVector;
			
			if(gameObject.name=="leftWall")
			{
				Debug.Log ("player moved right");
				moveVector=transform.right*pushIntensity;
				con.Move(moveVector);
			}
			if(gameObject.name=="rightWall")
			{
				Debug.Log ("player moved left");
				moveVector=transform.right*pushIntensity*-1;
				con.Move(moveVector);
			}
			
		}
	}
}
