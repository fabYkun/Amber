using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SunRotation : MonoBehaviour {
	void Update () {
        transform.Rotate(35 * Time.deltaTime, 0, 0);
    }
}
