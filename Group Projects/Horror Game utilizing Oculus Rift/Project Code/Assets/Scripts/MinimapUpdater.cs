using UnityEngine;
using System.Collections;

public class MinimapUpdater : MonoBehaviour {
	public Transform playerPosition;
	public GameObject MinimapCamera;
	public GameObject MinimapMarker;
	private Vector3 lstPosition;
	// Update is called once per frame
	void LateUpdate () {
		Vector3 newPosition = new Vector3 (playerPosition.position.x, playerPosition.position.y, playerPosition.position.z);
		//if (lstPosition != newPosition) {
						//transform.position = new Vector3 (playerPosition.position.x, playerPosition.position.y, playerPosition.position.z);
						 //MinimapCamera.transform.position = newPosition;
						//Vector3 markerVector3 = new Vector3(MinimapCamera.transform.position.x,MinimapCamera.transform.position.y + 10, MinimapCamera.transform.position.z);
						//Instantiate (MinimapMarker, markerVector3, MinimapCamera.transform.rotation);
						Vector3 markerVector3 = new Vector3(newPosition.x,newPosition.y + 50, newPosition.z);
						MinimapMarker.transform.position = markerVector3;
						MinimapMarker.transform.rotation = playerPosition.rotation;
						lstPosition = newPosition;
		//		}
	}
}
