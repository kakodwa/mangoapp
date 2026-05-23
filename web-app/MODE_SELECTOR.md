# Mode Selector Guide

## Where to Choose Demo or Live Mode

The web app now includes a visible **Mode Selector** in the navbar that shows you exactly which mode you're in.

### Location

Look in the **top navbar** (navigation bar at the top of the page):

```
[Logo] [Home] [Products] ... [Mode Badge] [Search] [Cart] [Profile]
```

The **Mode Badge** is located between the navigation links and the action buttons (Search, Cart, Profile).

### Visual Indicators

#### Demo Mode (No Backend)
- **Badge**: Yellow/Orange background
- **Text**: Shows "Demo"
- **Icon**: Database icon
- **Meaning**: You're using sample data, backend server is not running

#### Live Mode (With Backend)
- **Badge**: Green background
- **Text**: Shows "Live"
- **Icon**: Database icon
- **Meaning**: Connected to real API server with live data

### How to Use It

#### 1. Check Current Mode
Look at the colored badge in the navbar. It instantly shows whether you're in Demo or Live mode.

**Desktop:**
```
[Yellow Demo Badge] or [Green Live Badge]
```

**Mobile:**
Just the icon is shown to save space, but the color still indicates the mode.

#### 2. Click for More Information
Click on the mode badge to open a detailed information modal that explains:
- What your current mode means
- What features are available
- How to switch modes if you want

#### 3. The Information Modal

When you click the mode badge, a modal dialog appears with:

**For Demo Mode:**
- Explanation of demo data
- Features you can test
- Instructions to switch to Live mode
- "Refresh Page" button to try connecting to API again

**For Live Mode:**
- Confirmation of API connection
- Available features with live data
- What's working and what's not

### Switching Between Modes

#### From Demo to Live Mode (5 steps)
1. **Open terminal/command prompt**
2. **Start the backend server**
   ```bash
   python manage.py runserver
   ```
   Make sure it runs on `http://127.0.0.1:8000`
3. **Come back to the web app**
4. **Click the Mode Badge**
5. **Click "Refresh Page"** in the modal

The app will now reconnect and show "Live" mode.

#### From Live to Demo Mode
If the API server goes down, the app automatically:
- Detects the connection loss
- Falls back to demo data
- Updates the badge to "Demo" mode
- Shows a notification

## Technical Details

### How It Works

1. **On Page Load**
   - App checks if API server is available
   - Sets mode to 'live' if connected, 'demo' if not
   - Updates the badge color accordingly

2. **During Use**
   - App displays appropriate data source
   - Badge always shows current status
   - Users can click for details anytime

3. **In The Background**
   - `app.mode` property tracks current mode
   - `updateModeIndicator()` updates the badge
   - `showModeInfo()` displays the information modal

### Mode Badge HTML

```html
<span id="modeStatus" class="mode-badge demo-mode">
    <i class="fas fa-database"></i>
    <span id="modeText">Demo</span>
</span>
```

### Mode Badge Styling

**Demo Mode Colors:**
- Background: Light yellow (#FFF3CD)
- Text: Dark orange (#856404)
- Border: Pale yellow (#FFE69C)

**Live Mode Colors:**
- Background: Light green (#D4EDDA)
- Text: Dark green (#155724)
- Border: Pale green (#C3E6CB)

## FAQ

### Q: Where do I see which mode I'm in?
**A:** Look at the colored badge in the top navbar, between the navigation links and action buttons.

### Q: How do I know what mode means?
**A:** Click on the mode badge! A helpful modal will explain everything.

### Q: Can I choose to use demo mode even when API is available?
**A:** Currently, the app auto-detects the best mode. Demo is used when API is unavailable. For manual control, you can modify the JavaScript if needed.

### Q: What's the difference in what I see?
**A:** 
- **Demo**: Sample products, no login required, local storage only
- **Live**: Real products from database, user accounts, real transactions

### Q: If I switch modes, do I lose my cart?
**A:** No! Your cart is saved in your browser's local storage and persists across mode switches.

### Q: Why is the text hidden on mobile?
**A:** To save space. The color of the icon still shows the mode (yellow = demo, green = live).

### Q: Can I scroll on the mode info modal?
**A:** Yes! If the content is long, you can scroll within the modal.

## Screenshots

### Demo Mode
```
┌─────────────────────────────────────────┐
│ Logo  Nav Links  [🗄 Demo]  Search Cart│
└─────────────────────────────────────────┘
Yellow badge = Demo mode active
```

### Live Mode
```
┌─────────────────────────────────────────┐
│ Logo  Nav Links  [🗄 Live]  Search Cart │
└─────────────────────────────────────────┘
Green badge = Live mode active
```

### Mode Info Modal (Demo)
```
╔════════════════════════════════════════╗
║ Data Mode Information           [X]    ║
║                                        ║
║ ▶ Demo Mode                            ║
║   Using demo data.                     ║
║   ✓ Sample products and shops          ║
║   ✓ Offline browsing                   ║
║   ✓ Shopping cart works                ║
║                                        ║
║ ▶ How to Switch to Live Mode?          ║
║   1. python manage.py runserver        ║
║   2. Refresh page                      ║
║                                        ║
║          [Close]  [Refresh Page]       ║
╚════════════════════════════════════════╝
```

### Mode Info Modal (Live)
```
╔════════════════════════════════════════╗
║ Data Mode Information           [X]    ║
║                                        ║
║ ▶ Live API Mode                        ║
║   Connected to real API server         ║
║   ✓ Real products and shops            ║
║   ✓ User authentication                ║
║   ✓ Database persistence               ║
║   ✓ Payment processing                 ║
║                                        ║
║ ▶ What You Can Do                      ║
║   ✓ Browse real products               ║
║   ✓ Create account and login           ║
║   ✓ Manage profile and wallet          ║
║                                        ║
║              [Close]                   ║
╚════════════════════════════════════════╝
```

## Summary

- **Mode Badge Location:** Top navbar, between navigation and action buttons
- **Demo Mode:** Yellow badge, sample data, no backend needed
- **Live Mode:** Green badge, real data, backend connected
- **Click Badge:** Opens detailed information about current mode
- **Auto-Detect:** App automatically switches modes based on API availability
- **Mobile Friendly:** Responsive design works on all devices

Now you'll always know exactly which mode you're in and how to switch if needed!
