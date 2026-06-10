const BASE_URL = 'http://localhost:5000/api';

async function runTests() {
  console.log('=== STARTING MRC BACKEND END-TO-END FLOW TESTS ===\n');

  try {
    // 1. Trigger Service, Product and Slot seeding
    console.log('[1/7] Fetching services to trigger seeding...');
    const servicesRes = await fetch(`${BASE_URL}/services`);
    const services = await servicesRes.json();
    console.log(`Fetched ${services.length} services.`);

    console.log('[2/7] Fetching products to trigger seeding...');
    const productsRes = await fetch(`${BASE_URL}/admin/products`);
    const products = await productsRes.json();
    console.log(`Fetched ${products.length} products.`);

    console.log('[3/7] Fetching slots to trigger slot seeding...');
    const slotsRes = await fetch(`${BASE_URL}/admin/slots`);
    const allSlots = await slotsRes.json();
    console.log(`Fetched ${allSlots.length} slots from database.`);

    if (allSlots.length === 0) {
      throw new Error('Slot seeding failed, returned 0 slots.');
    }

    // 2. Admin Login / Seed
    console.log('\n[4/7] Testing Admin login/seeding...');
    const adminLoginRes = await fetch(`${BASE_URL}/admin/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'admin@mrcoach.in', password: 'admin1234' })
    });
    const adminData = await adminLoginRes.json();
    
    if (!adminLoginRes.ok) {
      throw new Error(`Admin login failed: ${adminData.message}`);
    }
    console.log('Admin login successful! Token received.');
    const adminToken = adminData.token;

    // 3. User Register & Login
    console.log('\n[5/7] Testing User Registration / Login...');
    const testEmail = `tester_${Date.now()}@test.com`;
    const userRegRes = await fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: 'Test User', email: testEmail, password: 'testuser123' })
    });
    let userData = await userRegRes.json();
    
    // If user already registered, do login
    if (!userRegRes.ok) {
      console.log('Registration failed, trying login...');
      const userLoginRes = await fetch(`${BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: testEmail, password: 'testuser123' })
      });
      userData = await userLoginRes.json();
      if (!userLoginRes.ok) {
        throw new Error(`User login failed: ${userData.message}`);
      }
    }
    console.log('User authenticated successfully!');
    const userToken = userData.token;

    // 4. Find an available slot for booking
    const targetSlot = allSlots.find(s => s.isAvailable && s.capacity > 0);
    if (!targetSlot) {
      throw new Error('No available slots found to test booking.');
    }
    console.log(`\n[6/7] Target slot chosen for booking: Date=${targetSlot.date}, Time=${targetSlot.time}, Current Capacity=${targetSlot.capacity}`);

    // 5. Perform booking
    console.log('Submitting booking...');
    const bookingRes = await fetch(`${BASE_URL}/bookings`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${userToken}`
      },
      body: JSON.stringify({
        serviceName: 'Yoga at Home',
        coachName: 'General',
        date: targetSlot.date,
        time: targetSlot.time,
        price: 99,
        mode: 'Online',
        bookingType: 'Demo',
        mobileNumber: '9999999999',
        address: '123 Test Street'
      })
    });
    const bookingData = await bookingRes.json();
    
    if (!bookingRes.ok) {
      throw new Error(`Booking creation failed: ${bookingData.message}`);
    }
    console.log('Booking confirmed on backend successfully!');

    // 6. Verify slot capacity has decreased
    console.log('\n[7/7] Verifying slot capacity decreased...');
    const verifySlotsRes = await fetch(`${BASE_URL}/admin/slots`);
    const verifySlots = await verifySlotsRes.json();
    const updatedSlot = verifySlots.find(s => s._id === targetSlot._id);
    
    if (!updatedSlot) {
      throw new Error('Could not find target slot in verification list.');
    }
    
    console.log(`Updated Slot: Date=${updatedSlot.date}, Time=${updatedSlot.time}, New Capacity=${updatedSlot.capacity}, Available=${updatedSlot.isAvailable}`);
    
    if (updatedSlot.capacity === targetSlot.capacity - 1) {
      console.log('=> SUCCESS: Slot capacity decremented by 1 correctly!');
    } else {
      throw new Error(`Capacity decrement mismatch. Expected ${targetSlot.capacity - 1}, but got ${updatedSlot.capacity}`);
    }

    console.log('\n=== ALL END-TO-END FLOW TESTS PASSED SUCCESSFULLY! ===');
  } catch (error) {
    console.error('\n!!! TEST FLOW FAILED !!!');
    console.error(error.message || error);
    process.exit(1);
  }
}

runTests();
