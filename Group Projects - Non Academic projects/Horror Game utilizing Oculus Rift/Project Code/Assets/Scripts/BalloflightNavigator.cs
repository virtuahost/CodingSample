using UnityEngine;
using System.Collections;

public class BalloflightNavigator : MonoBehaviour {
	
	public Transform[] path;
	
	private NavMeshAgent agent;
	private Animator anim;
	public int currDest=0;

	// Use this for initialization
	void Start () {
		agent= gameObject.GetComponent<NavMeshAgent>();
		anim = transform.FindChild("ballOfLightGeometry").GetComponent<Animator>();
		agent.SetDestination(path[0].position);
		anim.SetBool("isMoving",true);

	}
	
	// Update is called once per frame
	void Update () {
		anim.SetFloat("velocity", agent.velocity.magnitude);
	}
	
	public void navigateToNext()
	{
		if(currDest < (path.Length-1))
			currDest++;
		agent.SetDestination(path[currDest].position);
		anim.SetBool("isMoving",true);
		
	}
	
	public bool hasArrived()
	{
		Vector2 ballPos=new Vector2( transform.position.x, transform.position.z);
		Vector2 destPos=new Vector2( path[currDest].position.x, path[currDest].position.z);
		Debug.Log(Vector2.Distance(ballPos, destPos));
		if(agent.velocity.magnitude == 0 && Vector2.Distance(ballPos, destPos) < 0.01)
		{
			
			return true;
		}
		else
			return false;
	}
}
