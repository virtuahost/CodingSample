using UnityEngine;
using System.Collections;

public class CheckPoint : MonoBehaviour {

	public Vector3 lastPosition;
	public bool triggered;
	private float PlayerX;
	private float PlayerY;
	private float PlayerZ;
	public Transform PlayerPosition;
	public GameObject player;
	private Vector3 position;
	private PlayerController.PlayerState statePlayer ;
	public Vector3 GetPosition()
	{
		return this.position;
	}
	public void SetPosition(Vector3 temp)
	{
		this.position = temp;
	}


	// Use this for initialization
	void Start () {
		lastPosition = GameObject.FindGameObjectWithTag ("ChkPntState").GetComponent<CheckPointState> ().lastPosition;
		triggered = false;
		statePlayer = player.GetComponent<PlayerController>()._playerState;
		//statePlayer = Death;
	}

	void OnTriggerEnter(Collider other) {
		lastPosition = this.position;
	}


				

		
		//saveAttributes();
	//}
	
	//if(_playerState == PlayerState.Death){
		
		//loadStuff();
	//}

	//void saveAttributes() {
		//PlayerPrefs.SetFloat(PlayerPosition.transform.position.x);
		//PlayerPrefs.SetFloat(PlayerPosition.transform.position.y);
		//PlayerPrefs.SetFloat(PlayerPosition.transform.position.z);
	//}
	
	//void loadstuff () {
		//PlayerPosition.transform.position.x = (PlayerPrefs.GetFloat(PlayerX));
		//PlayerPosition.transform.position.y = (PlayerPrefs.GetFloat(PlayerY));
		//PlayerPosition.transform.position.z = (PlayerPrefs.GetFloat(PlayerZ));
	//}
	
	// Update is called once per frame


}
