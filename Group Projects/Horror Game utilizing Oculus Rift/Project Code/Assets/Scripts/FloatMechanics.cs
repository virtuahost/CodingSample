using UnityEngine;
using System.Collections;

public class FloatMechanics : MonoBehaviour {
	public GameObject monster;
	public GameObject pumpkin;
	public GameObject skeleton;
	private GameObject roomTrigger;
	private Transform soundRoom;
	// Use this for initialization
	void Start () {
		/*soundRoom=transform.FindChild("soundRoom");
		roomTrigger=soundRoom.FindChild("playerTrigger").gameObject;*/
	}
	
	// Update is called once per frame
	void Update () {
		/*bool playerEntered=roomTrigger.GetComponent<PlayerCheckerScript>().isPlayerInside;
		int scareSelection=roomTrigger.GetComponent<PlayerCheckerScript>().scareMode;
		if (scareSelection != -1 && playerEntered) {
			switch(scareSelection)
			{
			case 1:
				monster.audio.Play();
				skeleton.audio.Stop();
				pumpkin.audio.Stop();
				break;
			case 2:
				skeleton.audio.Play();
				monster.audio.Stop();
				pumpkin.audio.Stop();
				break;
			case 3:
				pumpkin.audio.Play();
				monster.audio.Stop();
				skeleton.audio.Stop();
				break;
			default:
				break;
			}
		}*/
	}
}
