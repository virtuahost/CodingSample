using UnityEngine;
using System.Collections;

public class BetweenWallBehaviour : MonoBehaviour {

	public Transform startPoint;
	public Transform endPoint;
	
	private Material stonesTexture;
	// Use this for initialization
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {
		float distance = Vector3.Distance(startPoint.position, endPoint.position);
		Vector3 direction = endPoint.position - startPoint.position;
		transform.position=startPoint.position+direction/2;
		transform.localScale=new Vector3(1, 1, distance*4.6f);
		transform.forward=direction.normalized;
		
		
	
	}
}
