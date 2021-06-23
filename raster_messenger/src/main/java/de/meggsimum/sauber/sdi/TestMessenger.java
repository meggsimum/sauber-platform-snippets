
/**
 * @author Lisa Scherf
 * Software AG, Darmstadt, Germany
 * 30.10.2019
 * 
 * @author Julian Kaeflein
 * geomer
 * 13.07.2020
 * 
 * Documentation: https://documentation.softwareag.com/onlinehelp/Rohan/num10-3/10-3_UM_webhelp/index.html#page/um-webhelp%2Fco-index_dg_17.html%23
 *
 * This example shows how to publish an event onto a Universal Messaging Channel.
 * When executed, an example heartbeat is send to the channel "HeartbeatChannel".
 * 
 */

package de.meggsimum.sauber.sdi;
import com.pcbsys.nirvana.client.*;
import java.text.SimpleDateFormat;
import org.json.*;

public class TestMessenger {
		
		public void publish(String[] rname, String chname, String testRegion, String testPollutant, String sourcename, String category) {
		
			// Get the timestamp
			Long currTime = System.currentTimeMillis()/1000;
			Long plusOneHr = currTime + 3600;
			Long plusTwoHr = plusOneHr + 3600;		
			nSessionAttributes nsa;
			try {
				
				// Connect to the Universal Messaging Server
				nsa = new nSessionAttributes(rname);
				nSession mySession=nSessionFactory.create(nsa);
				mySession.init();
				
				// Search and connect to a channel on the Universal Messaging Server
				//Create HeartbeatChannel
				nChannel myChannel;
			    try {
				nChannelAttributes cattrib = new nChannelAttributes(); 
				cattrib.setMaxEvents(0); 
				cattrib.setTTL(0); 
				cattrib.setType(nChannelAttributes.PERSISTENT_TYPE); 
				cattrib.setName(chname); 
				myChannel=mySession.createChannel(cattrib);
			    } catch(nChannelAlreadyExistsException e){
			    	nChannelAttributes chattr=new nChannelAttributes();
					chattr.setName(chname);
					myChannel=mySession.findChannel(chattr);
			    }
				
				SimpleDateFormat format = new SimpleDateFormat("HH");
				
				String readableTime = format.format((currTime+3600)*1000); 
				// raster_downloader uses predictionStartTime as name
				// get one hour ahead for correctly branded raster from server
			    
				// Create the JSONObject for the payload of the event with example data	    
			    String rasterURL = "https://www.geomer.de/dltemp/rasters/"+readableTime+".tif";
				
			    JSONObject payload = new JSONObject("{\"unit\":\"microgm-3\","
			    		+ "\"dataBbox\":\"SRID=3035;POLYGON((4029801 3029448, 4033146 3273436, 4285160 3270009, 4281827 3025941, 4029801 3029448))\","
			    		+ "\"interval\":3600}")
			    		.put("region", testRegion)
			    		.put("type", testPollutant)			    		
			    		.put("url", rasterURL)
			    		.put("creationTime", currTime)
			    		.put("predictionStartTime", plusOneHr)
			    		.put("predictionEndTime", plusTwoHr);	    
			    
			    String jsonpayload = new JSONObject("{\"category\": \"areal-forecast\", \"source\": \"hhi\"}")
			    		.put("payload",payload)
			    		.put("timestamp", currTime).toString();
				
				// Set the properties for the event with example data
				nEventProperties props = new nEventProperties();			
				props.put("timestamp", currTime);
				props.put("source",sourcename);
				props.put("category", category);		
				// Create an event with a tag, event properties and the payload
				nConsumeEvent evt = new nConsumeEvent(props,jsonpayload.getBytes());
				// publish the event to the connected Channel
				myChannel.publish(evt);
				System.out.println("Event was published.");
				// Close the session we opened
			    try {
			      nSessionFactory.close(mySession);
			    } catch (Exception ex) {
			    }
			    // Close any other sessions within this JVM so that we can exit
			    nSessionFactory.shutdown();
				
				// Handle errors
			} catch (Exception e) {
			    e.printStackTrace();
			    System.exit(1);
			}
	}
}