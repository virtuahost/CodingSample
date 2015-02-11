using UnityEngine;
using System.Collections;

public class CharacterFollowerBehaviour : MonoBehaviour {

	public Transform player;
	public GameObject footSteps;
	public GameObject breathing;

	private NavMeshAgent agent;
	private TBE_3DCore.TBE_Source footStepsSound;
	private TBE_3DCore.TBE_Source breathingSound;

	// Use this for initialization
	void Start () {
		agent = GetComponent<NavMeshAgent> ();
		footStepsSound=footSteps.GetComponent<TBE_3DCore.TBE_Source>();
		breathingSound=breathing.GetComponent<TBE_3DCore.TBE_Source>();
		
	}
	
	// Update is called once per frame
	void Update () {
		agent.SetDestination (player.position);
		float dist=(player.position - transform.position).magnitude;
		breathingSound.volume=(float)0.4/dist;
		//Debug.Log("Volume:"+0.2/dist);
		if (agent.velocity.sqrMagnitude < 1) {
			//Debug.Log("CluseBy");
			if (footStepsSound.isPlaying) {
				footStepsSound.Stop ();
			}
		} else {
			//Debug.Log("Arrived");
			if (!footStepsSound.isPlaying) {
				footStepsSound.Play ();
			}
		}
	}
}
