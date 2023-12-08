Office.onReady(function (info) {
    if (info.host === Office.HostType.Outlook) {
      document.getElementById("findTimeButton").onclick = findFreeTime;
    }
  });
  
  async function findFreeTime() {
    try {
      // Logic to find available time slots
      const availableTimeSlots = await findTimeInCalendar();
      // Display results or perform other actions
    } catch (error) {
      console.error(error);
    }
  }
  
  async function findTimeInCalendar() {
    // Use Microsoft Graph API to retrieve calendar data
    // Implement your logic to find available time slots
    // Return the result
  }
  