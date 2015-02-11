using UnityEngine;
using System.Collections;

public class SkeletonMover : MonoBehaviour {

	public Transform wall;
	public bool leftWall;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		Vector3 pos= new Vector3();
		if(leftWall){
			pos=wall.position+wall.right;
		}else{
			pos=wall.position-wall.right;
		}
			
			transform.position=new Vector3(transform.position.x, transform.position.y, pos.z);
	}
}
