using UnityEngine;
using System.Collections;

public class BallOfLightBehaviour : MonoBehaviour {

	public float regenRate;
	
	private SanitySetterScript sanitySetter;
	private bool isPlayerInside = false;
	private BalloflightNavigator nav;
	// Use this for initialization
	void Start () {	
		sanitySetter=GameObject.Find("sanitySetter").GetComponent<SanitySetterScript>();
		nav = transform.parent.GetComponent<BalloflightNavigator>();
	}
	
	// Update is called once per frame
	void OnTriggerEnter(Collider c)
	{
		if(c.gameObject.tag == "player")
		{
			sanitySetter.sanityRegen+=regenRate;
			if(nav.hasArrived())
				nav.navigateToNext();
			isPlayerInside = true;
		}
	}
	
	void OnTriggerExit(Collider c)
	{
		if(c.gameObject.tag == "player")
		{
			sanitySetter.sanityRegen=0;
			isPlayerInside = false;
		}
	}
	
	public bool getPlayerInside()
	{
		return isPlayerInside;
	}
	
}
