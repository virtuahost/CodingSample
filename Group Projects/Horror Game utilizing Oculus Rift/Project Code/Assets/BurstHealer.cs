using UnityEngine;
using System.Collections;

public class BurstHealer : MonoBehaviour {

	public float healAmount;
	public float healRate;
	
	private SanitySetterScript sanitySentter;
	private float totalHeal;
	private bool healed;
	// Use this for initialization
	void Start () {
		totalHeal=0;
		sanitySentter = GameObject.Find("sanitySetter").GetComponent<SanitySetterScript>();
		healed=false;
	}
	
	// Update is called once per frame
	void Update () {
		
	}
	
	IEnumerator healPlayer()
	{
		while(!healed)
		{
			sanitySentter.sanity+=healRate*Time.deltaTime;
			totalHeal+=healRate*Time.deltaTime;
			Debug.Log("healing!!!");
			if(totalHeal > healAmount)
			{
				healed=true;
				Debug.Log ("healed!!");
			}
			yield return null;
		}
		
	}
	
	void OnTriggerEnter(Collider c)
	{
		if(c.gameObject.tag == "player")
		{
			StartCoroutine("healPlayer");
			Debug.Log("healing Started");
		}
	}
}
