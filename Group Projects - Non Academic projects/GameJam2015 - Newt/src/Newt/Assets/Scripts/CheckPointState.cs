using UnityEngine;
using System.Collections;

public class CheckPointState : MonoBehaviour {
	public Vector3 lastPosition;
	public Transform PlayerPosition;
	public GameObject player;
	private PlayerController.PlayerState statePlayer ;
	void Start()
	{
		statePlayer = player.GetComponent<PlayerController> ()._playerState;
	}
	void Update () {
		if(statePlayer == PlayerController.PlayerState.Death){
			//PlayerX =(PlayerPosition.transform.position.x);
			//PlayerY =(PlayerPosition.transform.position.y);
			//PlayerZ =(PlayerPosition.transform.position.z);
			lastPosition = PlayerPosition.transform.position;
//			Debug.Log(lastPosition);
		}
	}	
}
