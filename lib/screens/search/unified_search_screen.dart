import 'dart:async';
import 'package:flutter/material.dart';
import '../../providers/search_provider.dart';
import '../../models/search_result_item.dart';

// --- DESIGN SYSTEM & LAYOUT IMPORTS ---
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_dropdown.dart';
import '../../theme/design_system/app_button.dart';

// --- NATIVE DOMAIN MODELS ---
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';
import '../../models/property_model.dart';
import '../../models/shop_model.dart';
import '../../models/event_model.dart';
import '../../models/lodge_model.dart';

// --- PLUGGED NATIVE FEED CARDS ---
import '../../screens/products/product_card.dart';
import '../../screens/shops/shop_card.dart';
import '../../screens/properties/property_card.dart';
import '../../widgets/hospitality/lodge_card.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/web_footer.dart';

class UnifiedSearchScreen extends StatefulWidget {
  const UnifiedSearchScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends State<UnifiedSearchScreen> {
  final SearchProvider _provider = SearchProvider();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Track subcategory and brand parameters locally inside search UI
  String? _selectedSubCategory;
  String? _selectedBrand;

  final List<Map<String, String>> _types = [
    {'key': 'all', 'label': 'All items'},
    {'key': 'product', 'label': 'Products'},
    {'key': 'property', 'label': 'Properties'},
    {'key': 'lodge', 'label': 'Lodges'},
    {'key': 'event', 'label': 'Events'},
    {'key': 'shop', 'label': 'Shops'},
  ];

  final List<String> _malawiDistricts = [
    'Balaka', 'Blantyre', 'Chikwawa', 'Chiradzulu', 'Chitipa', 'Dedza', 'Dowa',
    'Karonga', 'Kasungu', 'Likoma', 'Lilongwe', 'Machinga', 'Mangochi', 'Mchinji',
    'Mulanje', 'Mwanza', 'Mzimba', 'Nkhata Bay', 'Nkhotakota', 'Nsanje', 'Ntcheu',
    'Ntchisi', 'Phalombe', 'Rumphi', 'Salima', 'Thyolo', 'Zomba'
  ];

  final List<Map<String, String>> _productCategories = [
    {'key': 'Fashion', 'label': 'Fashion'},
    {'key': 'Electronics', 'label': 'Electronics'},
    {'key': 'Groceries', 'label': 'Groceries'},
    {'key': 'Home & Living', 'label': 'Home & Living'},
    {'key': 'Beauty & Personal Care', 'label': 'Beauty & Personal Care'},
    {'key': 'Health & Wellness', 'label': 'Health & Wellness'},
    {'key': 'Agriculture', 'label': 'Agriculture'},
    {'key': 'Vehicles', 'label': 'Vehicles'},
    {'key': 'Construction & Hardware', 'label': 'Construction & Hardware'},
    {'key': 'Books & Education', 'label': 'Books & Education'},
    {'key': 'Sports & Outdoors', 'label': 'Sports & Outdoors'},
    {'key': 'Baby & Kids', 'label': 'Baby & Kids'},
    {'key': 'Food & Beverages', 'label': 'Food & Beverages'},
    {'key': 'Pets & Animals', 'label': 'Pets & Animals'},
    {'key': 'Office Supplies', 'label': 'Office Supplies'},
    {'key': 'Entertainment', 'label': 'Entertainment'},
    {'key': 'Services', 'label': 'Services'},
    {'key': 'Industrial Equipment', 'label': 'Industrial Equipment'},
  ];

  final Map<String, Map<String, List<String>>> _categorySubCategoryBrands = {
    'Electronics': {
      'Smartphones': ['Apple', 'Samsung', 'Xiaomi', 'Google', 'OnePlus'],
      'Tablets': ['Apple (iPad)', 'Samsung Galaxy Tab', 'Lenovo Tab', 'Amazon Fire'],
      'Laptops': ['Lenovo', 'Dell', 'HP', 'Apple MacBook', 'ASUS'],
      'Desktop Computers': ['Dell', 'HP', 'Apple iMac', 'Lenovo ThinkCentre'],
      'Computer Accessories': ['Logitech', 'Razer', 'Corsair', 'Anker'],
      'Printers & Scanners': ['HP', 'Canon', 'Epson', 'Brother'],
      'Networking Equipment': ['Cisco', 'TP-Link', 'Netgear', 'ASUS'],
      'Televisions': ['Samsung', 'LG', 'Sony', 'TCL', 'Hisense'],
      'Audio Systems': ['Bose', 'Sony', 'JBL', 'Sonos', 'Sennheiser'],
      'Cameras': ['Canon', 'Nikon', 'Sony', 'Fujifilm', 'GoPro'],
      'Smart Watches': ['Apple Watch', 'Samsung Galaxy Watch', 'Garmin', 'Fitbit'],
      'Gaming Consoles': ['Sony PlayStation', 'Microsoft Xbox', 'Nintendo Switch'],
      'Gaming Accessories': ['Razer', 'Logitech G', 'SteelSeries', 'HyperX'],
      'Mobile Accessories': ['Anker', 'Belkin', 'Spigen', 'OtterBox'],
      'Storage Devices': ['SanDisk', 'Samsung', 'Western Digital', 'Seagate'],
      'Power Banks': ['Anker', 'RAVPower', 'Xiaomi', 'Belkin'],
      'Chargers & Cables': ['Belkin', 'Anker', 'Apple', 'Samsung'],
      'Home Appliances': ['LG', 'Samsung', 'Whirlpool', 'Bosch'],
      'Kitchen Appliances': ['Philips', 'Instant Pot', 'KitchenAid', 'Cuisinart'],
      'Smart Home Devices': ['Google Nest', 'Amazon Echo', 'Philips Hue', 'Ring'],
    },
    'Groceries': {
      'Rice & Grains': ["Ben's Original", 'Mahatma', 'Tilda', 'Lundberg'],
      'Flour': ['Gold Medal', 'King Arthur', 'Pillsbury'],
      'Cooking Oil': ['Crisco', 'Wesson', 'Bertolli', 'Mazola'],
      'Sugar': ['Domino Sugar', 'C&H', 'In the Raw'],
      'Salt & Spices': ['McCormick', 'Morton Salt', 'Badia', 'Simply Organic'],
      'Pasta & Noodles': ['Barilla', 'De Cecco', 'Ronzoni', 'Nissin'],
      'Breakfast Foods': ["Kellogg's", 'General Mills', 'Quaker Oats', 'Post'],
      'Canned Foods': ['Heinz', 'Campbell\'s', 'Del Monte', 'Green Giant'],
      'Snacks': ["Lay's", 'Doritos', 'Pringles', 'Cheetos'],
      'Biscuits': ['Oreo', 'McVitie\'s', 'Chips Ahoy!', 'Belvita'],
      'Dairy Products': ['Kraft', 'Land O\'Lakes', 'Horizon Organic', 'Chobani'],
      'Eggs': ["Eggland's Best", 'Happy Egg Co.', 'Vital Farms'],
      'Frozen Foods': ['Birds Eye', 'Amy\'s Kitchen', 'Stouffer\'s', 'Digiorno'],
      'Fresh Vegetables': ['Dole', 'Fresh Express', 'Organic Girl'],
      'Fresh Fruits': ['Chiquita', 'Dole', 'Driscoll\'s', 'Del Monte'],
      'Meat & Poultry': ['Tyson Foods', 'Perdue', 'Pilgrim\'s', 'Applegate'],
      'Seafood': ['Bumble Bee', 'StarKist', 'Chicken of the Sea', 'Gorton\'s'],
      'Cleaning Supplies': ['Clorox', 'Lysol', 'Mr. Clean', 'Method'],
      'Household Essentials': ['Procter & Gamble (P&G)', 'Kimberly-Clark', 'Unilever'],
    },
    'Fashion': {
      'Shirts': ['Ralph Lauren', 'Tommy Hilfiger', 'Calvin Klein', 'Brooks Brothers'],
      'T-Shirts': ['Hanes', 'Gildan', 'Fruit of the Loom', 'Champion'],
      'Trousers': ['Dockers', 'Levi\'s', 'H&M', 'Zara'],
      'Jeans': ['Levi\'s', 'Wrangler', 'Lee', 'Diesel'],
      'Suits': ['Hugo Boss', 'Armani', 'Ted Baker', 'Zara Suit'],
      'Jackets': ['The North Face', 'Patagonia', 'Columbia', 'Arc\'teryx'],
      'Shoes': ['Nike', 'Adidas', 'Puma', 'Reebok', 'New Balance'],
      'Sandals': ['Birkenstock', 'Crocs', 'Teva', 'Chacos'],
      'Watches': ['Rolex', 'Seiko', 'Casio', 'Omega', 'Fossil'],
      'Bags': ['Samsonite', 'Herschel', 'Tumi', 'American Tourister'],
      'Dresses': ['Zara', 'H&M', 'Mango', 'ASOS'],
      'Tops': ['H&M', 'Zara', 'Forever 21', 'Express'],
      'Skirts': ['ASOS', 'Zara', 'H&M', 'Mango'],
      'Handbags': ['Louis Vuitton', 'Michael Kors', 'Coach', 'Gucci', 'Kate Spade'],
      'Heels': ['Jimmy Choo', 'Christian Louboutin', 'Steve Madden', 'Nine West'],
      'Jewelry': ['Tiffany & Co.', 'Pandora', 'Swarovski', 'Cartier'],
      'Boys Clothing': ['Carter\'s', 'OshKosh B\'gosh', 'The Children\'s Place'],
      'Girls Clothing': ['Gap Kids', 'Carter\'s', 'H&M Kids', 'Gymboree'],
      'School Uniforms': ['French Toast', 'Lands\' End', 'School Apparel'],
      'Underwear': ['Calvin Klein', 'Hanes', 'Victoria\'s Secret', 'Fruit of the Loom'],
      'Sportswear': ['Adidas', 'Nike', 'Under Armour', 'Puma', 'Lululemon'],
      'Traditional Wear': ['Manyavar', 'Fabindia', 'Biba', 'W for Woman'],
      'Hats & Caps': ['New Era', 'Adidas', 'Nike', 'Carhartt'],
      'Sunglasses': ['Ray-Ban', 'Oakley', 'Gucci', 'Prada'],
      'Belts': ['Gucci', 'Hermes', 'Levi\'s', 'Tommy Hilfiger'],
    },
    'Home & Living': {
      'Furniture': ['IKEA', 'Ashley Furniture', 'Wayfair', 'La-Z-Boy'],
      'Bedding': ['Brooklinen', 'Boll & Branch', 'Utopia Bedding'],
      'Curtains': ['Pottery Barn', 'West Elm', 'IKEA Curtains'],
      'Carpets & Rugs': ['Safavieh', 'Ruggable', 'Mohawk Home'],
      'Kitchenware': ['Pyrex', 'OXO', 'Tupperware', 'Corelle'],
      'Cookware': ['Le Creuset', 'Calphalon', 'T-fal', 'Lodge'],
      'Dining Sets': ['Corelle', 'Lenox', 'Fiesta', 'Gibson'],
      'Home Decor': ['West Elm', 'HomeGoods', 'Target Threshold'],
      'Lighting': ['Philips Hue', 'GE Lighting', 'Lutron'],
      'Storage & Organization': ['Tupperware', 'Rubbermaid', 'The Container Store'],
      'Bathroom Accessories': ['Kohler', 'Moen', 'Delta Faucet'],
      'Cleaning Equipment': ['Dyson', 'Shark', 'Bissell', 'iRobot Roomba'],
      'Garden Furniture': ['Tuuci', 'Brown Jordan', 'Keter'],
      'Mattresses': ['Tempur-Pedic', 'Casper', 'Sealy', 'Serta', 'Purple'],
    },
    'Beauty & Personal Care': {
      'Makeup': ['MAC Cosmetics', 'Maybelline', "L'Oréal", 'Fenty Beauty', 'Estée Lauder'],
      'Skincare': ['The Ordinary', 'CeraVe', 'Neutrogena', 'Clinique', 'La Roche-Posay'],
      'Hair Care': ['Olaplex', 'Pantenes', "L'Oréal Professionnel", 'Redken'],
      'Hair Extensions': ['Bellami Hair', 'Zala', 'Luxy Hair'],
      'Perfumes': ['Chanel', 'Dior', 'Gucci', 'Tom Ford', 'Versace'],
      'Deodorants': ['Dove', 'Old Spice', 'Secret', 'Degree', 'Native'],
      'Bath & Body': ['Bath & Body Works', 'Aveeno', 'Nivea', 'Lush'],
      'Men\'s Grooming': ['Jack Black', 'Baxter of California', 'Bevel'],
      'Shaving Supplies': ['Gillette', 'Harry\'s', 'Dollar Shave Club'],
      'Nail Care': ['OPI', 'Sally Hansen', 'Essie'],
      'Beauty Tools': ['Dyson Supersonic', 'Revlon One-Step', 'Foreo'],
      'Personal Hygiene': ['Colgate', 'Crest', 'Oral-B', 'Listerine'],
    },
    'Health & Wellness': {
      'Vitamins': ['Nature\'s Bounty', 'Centrum', 'Nature Made', 'Vitafusion'],
      'Supplements': ['GNC', 'Optimum Nutrition', 'MuscleTech', 'NOW Foods'],
      'First Aid': ['Band-Aid', 'Neosporin', 'Johnson & Johnson'],
      'Medical Devices': ['Medtronic', 'Philips Healthcare', 'GE HealthCare'],
      'Face Masks': ['3M', 'Honeywell', 'Kimberly-Clark'],
      'Blood Pressure Monitors': ['Omron', 'Withings', 'Beurer'],
      'Thermometers': ['Braun', 'iHealth', 'Vicks'],
      'Fitness Equipment': ['Peloton', 'Bowflex', 'NordicTrack', 'Sunny Health'],
      'Weight Management': ['WeightWatchers', 'SlimFast', 'Optavia'],
      'Sexual Wellness': ['Durex', 'Trojan', 'LELO', 'K-Y'],
      'Mobility Aids': ['Drive DeVilbiss Healthcare', 'Invacare', 'Pride Mobility'],
      'Health Monitoring Devices': ['Fitbit', 'Apple Watch', 'Garmin', 'Whoop'],
    },
    'Agriculture': {
      'Seeds': ['Corteva (Pioneer)', 'Monsanto (Bayer)', 'Syngenta', 'Burpee'],
      'Fertilizers': ['Miracle-Gro', 'Scotts', 'Yara', 'Milorganite'],
      'Pesticides': ['Bayer CropScience', 'Syngenta', 'BASF', 'FMC'],
      'Herbicides': ['Roundup', 'Bayer', 'BASF', 'Dow AgroSciences'],
      'Farm Tools': ['Fiskars', 'John Deere Tools', 'Corona', 'True Temper'],
      'Irrigation Equipment': ['Netafim', 'Rain Bird', 'Hunter Industries', 'Toro'],
      'Animal Feed': ['Purina Animal Nutrition', 'Cargill', 'Nutrena', 'Land O\'Lakes'],
      'Livestock': ['ABS Global', 'Genus PLC', 'CRI (Cooperative Resources)'],
      'Poultry Equipment': ['Big Dutchman', 'Chore-Time', 'Val-Co'],
      'Fish Farming': ['Pentair AES', 'Skretting', 'Zeigler Bros'],
      'Greenhouse Equipment': ['Ludvig Svensson', 'Rough Brothers', 'Atlas Greenhouse'],
      'Farm Machinery': ['John Deere', 'Case IH', 'New Holland', 'Massey Ferguson', 'Kubota'],
      'Beekeeping': ['Dadant & Sons', 'Mann Lake', 'Brushy Mountain'],
      'Veterinary Supplies': ['Zoetis', 'Boehringer Ingelheim', 'Merck Animal Health', 'Elanco'],
    },
    'Vehicles': {
      'Cars': ['Toyota', 'Honda', 'Ford', 'BMW', 'Mercedes-Benz', 'Hyundai'],
      'Motorcycles': ['Harley-Davidson', 'Honda Moto', 'Yamaha', 'Kawasaki', 'Ducati'],
      'Bicycles': ['Trek', 'Specialized', 'Giant', 'Cannondale', 'Santa Cruz'],
      'Trucks': ['Ford F-Series', 'Chevrolet Silverado', 'RAM Trucks', 'GMC Sierra'],
      'Buses': ['Volvo Buses', 'Mercedes-Benz Buses', 'Scania', 'Blue Bird'],
      'Tractors': ['John Deere', 'Kubota', 'Mahindra', 'New Holland'],
      'Vehicle Parts': ['Bosch', 'Denso', 'ACDelco', 'Magna'],
      'Tires': ['Michelin', 'Bridgestone', 'Goodyear', 'Continental', 'Pirelli'],
      'Batteries': ['Interstate Batteries', 'Optima Batteries', 'DieHard'],
      'Oils & Lubricants': ['Mobil 1', 'Castrol', 'Shell Rotella', 'Valvoline', 'Pennzoil'],
      'Car Electronics': ['Pioneer', 'Kenwood', 'Alpine', 'Sony Car Audio'],
      'Car Accessories': ['WeatherTech', 'Yeti', 'Thule', 'Yakima'],
      'Vehicle Tools': ['Snap-on', 'Craftsman', 'Mac Tools', 'Husky'],
    },
    'Construction & Hardware': {
      'Cement': ['LafargeHolcim', 'CEMEX', 'HeidelbergCement', 'Cemex'],
      'Bricks & Blocks': ['Wienerberger', 'Boral', 'Acme Brick'],
      'Roofing Materials': ['GAF', 'Owens Corning', 'CertainTeed'],
      'Paint': ['Sherwin-Williams', 'Benjamin Moore', 'Behr', 'Valspar', 'PPG'],
      'Plumbing Supplies': ['Moen', 'Kohler', 'Delta', 'SharkBite', 'Charlotte Pipe'],
      'Electrical Supplies': ['Schneider Electric', 'Legrand', 'Leviton', 'Eaton'],
      'Hand Tools': ['Stanley', 'Craftsman', 'Estwing', 'Channellock', 'Klein Tools'],
      'Power Tools': ['DeWalt', 'Milwaukee', 'Makita', 'Bosch', 'Ryobi', 'Black+Decker'],
      'Safety Equipment': ['3M', 'Honeywell Safety', 'MSA Safety', 'Ansell'],
      'Doors & Windows': ['Andersen', 'Pella', 'Jeld-Wen', 'Marvin'],
      'Tiles': ['Mohawk Industries', 'Daltile', 'Marazzi'],
      'Timber': ['Weyerhaeuser', 'Georgia-Pacific', 'West Fraser'],
      'Steel': ['ArcelorMittal', 'Nucor', 'US Steel', 'Nippon Steel'],
      'Fasteners': ['Simpson Strong-Tie', 'Hillman', 'Grip-Rite'],
      'Welding Equipment': ['Lincoln Electric', 'Miller Electric', 'ESAB', 'Hobart'],
    },
    'Books & Education': {
      'Textbooks': ['Pearson', 'McGraw Hill', 'Cengage', 'HMH'],
      'Children\'s Books': ['Scholastic', 'Penguin Kids', 'Dr. Seuss Enterprises', 'Disney'],
      'Fiction': ['Penguin Random House', 'HarperCollins', 'Simon & Schuster', 'Macmillan'],
      'Non-Fiction': ['HarperCollins', 'Penguin Press', 'National Geographic', 'Norton'],
      'Religious Books': ['Zondervan', 'Thomas Nelson', 'Deseret Book', 'Crossway'],
      'Business Books': ['Harvard Business Review (HBR) Press', 'Wiley', 'Kogan Page'],
      'Educational Materials': ['McGraw Hill Education', 'Scholastic Classroom', 'Kaplan'],
      'School Supplies': ['Crayola', 'Fiskars Kids', 'Elmer\'s', 'Five Star'],
      'Office Stationery': ['Mead', 'Bic', 'Paper Mate', 'Five Star'],
      'Dictionaries': ['Merriam-Webster', 'Oxford University Press', 'Collins'],
      'E-books': ['Amazon Kindle', 'Kobo', 'Google Play Books', 'Apple Books'],
    },
    'Sports & Outdoors': {
      'Football': ['Wilson', 'Adidas', 'Nike', 'Under Armour', 'Spalding'],
      'Basketball': ['Spalding', 'Wilson', 'Molten', 'Nike'],
      'Volleyball': ['Mikasa', 'Tachikara', 'Baden', 'Molten'],
      'Tennis': ['Wilson', 'Babolat', 'Head', 'Yonex', 'Penn'],
      'Gym Equipment': ['Life Fitness', 'Rogue Fitness', 'Matrix', 'Bowflex'],
      'Fitness Accessories': ['Under Armour', 'Fitbit', 'Nike', 'Lululemon'],
      'Camping Gear': ['Coleman', 'REI Co-op', 'Yeti', 'The North Face'],
      'Fishing Equipment': ['Shimano', 'Daiwa', 'Penn Fishing', 'Abu Garcia'],
      'Cycling': ['Specialized', 'Trek', 'Giant', 'Cannondale'],
      'Outdoor Clothing': ['Patagonia', 'The North Face', 'Columbia', 'Arc\'teryx'],
      'Swimming': ['Speedo', 'TYR', 'Arena', 'Intex'],
      'Hiking': ['Salomon', 'Merrell', 'Keen', 'Columbia', 'Osprey'],
    },
    'Baby & Kids': {
      'Baby Clothing': ['Carter\'s', 'Gerber Childrenswear', 'BabyGap'],
      'Baby Shoes': ['Robeez', 'Stride Rite', 'Carter\'s Shoes'],
      'Diapers': ['Pampers', 'Huggies', 'Luvs', 'The Honest Company'],
      'Baby Food': ['Gerber', 'Beech-Nut', 'Plum Organics', 'Happy Baby'],
      'Feeding Supplies': ['Dr. Brown\'s', 'Philips Avent', 'Munchkin', 'Tommee Tippee'],
      'Strollers': ['Bugaboo', 'Graco', 'UPPAbaby', 'Chicco', 'Baby Jogger'],
      'Car Seats': ['Graco', 'Chicco', 'Britax', 'Nuna', 'Evenflo'],
      'Toys': ['LEGO', 'Mattel (Barbie/Hot Wheels)', 'Hasbro', 'Fisher-Price', 'Melissa & Doug'],
      'School Bags': ['JanSport', 'Skip Hop', 'Pottery Barn Kids', 'Adidas Kids'],
      'Children\'s Furniture': ['Delta Children', 'Pottery Barn Kids', 'IKEA Kids'],
      'Baby Care Products': ['Johnson\'s Baby', 'Aveeno Baby', 'Mustela', 'Aquaphor'],
    },
    'Food & Beverages': {
      'Restaurants': ['Olive Garden', 'Applebee\'s', 'Chili\'s', 'Texas Roadhouse'],
      'Fast Food': ['McDonald\'s', 'Subway', 'Starbucks', 'Burger King', 'KFC', 'Wendy\'s'],
      'Bakery': ['Cinnabon', 'Panera Bread', 'Entenmann\'s', 'Sara Lee'],
      'Cakes': ['Betty Crocker', 'Duncan Hines', 'Pillsbury', 'Nothing Bundt Cakes'],
      'Coffee': ['Starbucks', 'Dunkin\'', 'Peet\'s Coffee', 'Nespresso', 'Folgers'],
      'Tea': ['Lipton', 'Twinings', 'Yogi Tea', 'Bigelow', 'Tazo'],
      'Soft Drinks': ['Coca-Cola', 'Pepsi', 'Dr Pepper', 'Sprite', 'Fanta'],
      'Juices': ['Tropicana', 'Simply Orange', 'Ocean Spray', 'Welch\'s', 'Minute Maid'],
      'Bottled Water': ['Evian', 'Fiji Water', 'Aquafina', 'Dasani', 'Nestle Pure Life'],
      'Energy Drinks': ['Red Bull', 'Monster Energy', 'Rockstar', 'Celsius'],
      'Local Foods': ['Uber Eats', 'Doordash', 'Grubhub'],
      'Catering': ['Compass Group', 'Aramark', 'Sodexo'],
    },
    'Pets & Animals': {
      'Dog Food': ['Royal Canin', 'Blue Buffalo', 'Purina Pro Plan', 'Hill\'s Science Diet'],
      'Cat Food': ['Fancy Feast', 'Friskies', 'Royal Canin Cat', 'Purina ONE Cat'],
      'Bird Supplies': ['Kaytee', 'ZuPreem', 'Hartz'],
      'Fish Supplies': ['Tetra', 'Fluval', 'API (Aquarium Pharmaceuticals)'],
      'Pet Accessories': ['Kong', 'Ruffwear', 'Frisco', 'Kurgo'],
      'Pet Toys': ['BarkBox', 'Kong Toys', 'Chuckit!', 'Nylabone'],
      'Pet Grooming': ['Wahl Clipper (Pet)', 'FURminator', 'Oster', 'Burt\'s Bees Pets'],
      'Pet Medicines': ['Frontline', 'Heartgard', 'NexGard', 'Bravecto', 'Apoquel'],
      'Animal Housing': ['Midwest Homes for Pets', 'Prevue Pet Products', 'Petmate'],
      'Livestock Supplies': ['Tarter USA', 'Tractor Supply Co.', 'Behlen Country'],
    },
    'Office Supplies': {
      'Paper': ['Hammermill', 'HP Papers', 'Georgia-Pacific', 'Xerox'],
      'Pens & Pencils': ['Bic', 'Pilot', 'Paper Mate', 'Uni-ball', 'Pentel', 'Ticonderoga'],
      'Notebooks': ['Moleskine', 'Five Star', 'Mead', 'Leuchtturm1917', 'Rhodia'],
      'Filing Supplies': ['Smead', 'Pendaflex', 'Avery'],
      'Office Furniture': ['Steelcase', 'Herman Miller', 'Haworth', 'HON'],
      'Office Electronics': ['Brother', 'HP', 'Canon', 'Epson', 'Casio'],
      'Ink & Toner': ['HP', 'Epson', 'Brother', 'Canon'],
      'Calculators': ['Texas Instruments', 'Casio', 'HP'],
      'Whiteboards': ['Quartet', 'Expo', 'Ubrands'],
      'Office Storage': ['Fellowes', 'Rubbermaid', 'Bankers Box'],
    },
    'Entertainment': {
      'Musical Instruments': ['Fender', 'Gibson', 'Yamaha Music', 'Ibanez', 'Roland'],
      'Movies': ['Walt Disney Pictures', 'Warner Bros.', 'Universal Pictures', 'Paramount'],
      'Music': ['Universal Music Group', 'Sony Music', 'Warner Music Group', 'Spotify'],
      'Video Games': ['Nintendo', 'Electronic Arts (EA)', 'Activision Blizzard', 'Ubisoft'],
      'Board Games': ['Hasbro', 'Mattel Games', 'Asmodee', 'Ravensburger'],
      'Toys': ['Mattel', 'LEGO Group', 'Hasbro', 'Spin Master'],
      'Party Supplies': ['Party City', 'Unique Industries', 'Creative Converting'],
      'Event Equipment': ['JBL Professional', 'Yamaha Pro Audio', 'Shure', 'Chauvet DJ'],
      'Karaoke Systems': ['Singing Machine', 'VocoPro', 'Grand Videoke'],
      'Streaming Devices': ['Roku', 'Amazon Fire TV', 'Apple TV', 'Google Chromecast'],
    },
    'Services': {
      'Cleaning Services': ['Merry Maids', 'The Maids', 'Molly Maid'],
      'Plumbing': ['Roto-Rooter', 'Mr. Rooter', 'Benjamin Franklin Plumbing'],
      'Electrical Services': ['Mr. Electric', 'Lemberg', 'Mister Sparky'],
      'Carpentry': ['Handyman Connection', 'Mr. Handyman', 'House Doctors'],
      'Painting': ['CertaPro Painters', 'Five Star Painting', '360° Painting'],
      'Computer Repair': ['Geek Squad', 'uBreakiFix', 'Rescuecom'],
      'Phone Repair': ['uBreakiFix', 'CPR Cell Phone Repair', 'Apple Support'],
      'Graphic Design': ['99designs', 'Fiverr Pro', 'Upwork Enterprise'],
      'Photography': ['Shutterfly', 'Getty Images Creative', 'Portrait Innovations'],
      'Videography': ['Getty Images Video', 'Shutterstock Custom', 'Vimeo Enterprise'],
      'Event Planning': ['Cvent', 'Bizzabo', 'Eventbrite Organizers'],
      'Catering': ['Aramark', 'Sodexo Catering', 'Compass Group'],
      'Laundry': ['Tide Cleaners', 'Laundromat', 'DryClean Depot'],
      'Transport': ['Uber', 'Lyft', 'BlaBlaCar'],
      'Delivery': ['FedEx', 'UPS', 'DHL', 'Amazon Logistics'],
      'Tutoring': ['Kumon', 'Sylvan Learning', 'Varsity Tutors', 'Princeton Review'],
      'Legal Services': ['LegalZoom', 'Rocket Lawyer', 'UpCounsel'],
      'Accounting': ['H&R Block', 'TurboTax Live', 'Ernst & Young (EY)', 'PwC'],
      'Consultancy': ['McKinsey & Company', 'Boston Consulting Group (BCG)', 'Bain & Company'],
      'Beauty Services': ['Ulta Beauty Salon', 'Supercuts', 'Regis Salon', 'Drybar'],
    },
    'Industrial Equipment': {
      'Generators': ['Generac', 'Caterpillar (CAT)', 'Cummins', 'Honda Power Equipment'],
      'Air Compressors': ['Ingersoll Rand', 'Atlas Copco', 'Campbell Hausfeld', 'DeWalt'],
      'Welding Machines': ['Miller Electric', 'Lincoln Electric', 'Hobart', 'ESAB'],
      'Water Pumps': ['Grundfos', 'Goulds Water Technology', 'Flotec'],
      'Factory Machinery': ['Siemens', 'ABB', 'Mitsubishi Electric', 'Bosch Rexroth'],
      'Packaging Equipment': ['Syntegon (Bosch Packaging)', 'Multivac', 'Sealed Air'],
      'Laboratory Equipment': ['Thermo Fisher Scientific', 'Agilent Technologies', 'VWR'],
      'Solar Equipment': ['Canadian Solar', 'First Solar', 'SunPower', 'Enphase Energy'],
      'Heavy Machinery': ['Caterpillar (CAT)', 'Komatsu', 'John Deere Construction', 'Volvo CE'],
      'Forklifts': ['Toyota Material Handling', 'Hyster-Yale', 'Crown Equipment'],
      'Industrial Tools': ['Hilti', 'Milwaukee Tool', 'Proto', 'Ingersoll Rand Tools'],
      'Safety Equipment': ['Honeywell', '3M Safety', 'MSA Safety', 'Ansell Industrial'],
      'Electrical Motors': ['Baldor-Reliance (ABB)', 'WEG', 'Nidec Motor'],
      'Manufacturing Equipment': ['Fanuc Robotics', 'Yaskawa Motoman', 'KUKA', 'ABB Robotics'],
    }
  };

  final List<Map<String, String>> _propertyCategories = [
    {'key': 'house', 'label': 'House'},
    {'key': 'apartment', 'label': 'Apartment'},
    {'key': 'land', 'label': 'Land'},
    {'key': 'commercial', 'label': 'Commercial'},
  ];

  final List<Map<String, String>> _lodgeCategories = [
    {'key': 'hotel', 'label': 'Hotel'},
    {'key': 'lodge', 'label': 'Lodge'},
    {'key': 'guest_house', 'label': 'Guest House'},
    {'key': 'apartment', 'label': 'Apartment'},
    {'key': 'villa', 'label': 'Villa'},
    {'key': 'resort', 'label': 'Resort'},
  ];

  @override
  void initState() {
    super.initState();
    _provider.fetchItems();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _provider.fetchItems();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _provider.updateFilters(query: query);
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final typeWithSubFilters = _provider.selectedType == 'product' || 
                                         _provider.selectedType == 'property' || 
                                         _provider.selectedType == 'lodge';

              return AnimatedBuilder(
                animation: _provider,
                builder: (context, child) {
                  // Setup cascading structures locally for the dropdowns
                  final Map<String, List<String>>? subCategoryMap = _categorySubCategoryBrands[_provider.selectedCategory];
                  final List<String> availableSubCategories = subCategoryMap?.keys.toList() ?? [];
                  final List<String> availableBrands = (_selectedSubCategory != null && subCategoryMap != null)
                      ? (subCategoryMap[_selectedSubCategory] ?? [])
                      : [];

                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Filter Search Results',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: AppSpacing.sm),

                          AppDropdown<String>(
                            label: 'Location District',
                            value: _provider.selectedDistrict,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Districts')),
                              ..._malawiDistricts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                            ],
                            onChanged: (val) {
                              _provider.updateFilters(
                                district: val,
                                category: SearchProvider.isUnchanged,
                                listingPurpose: SearchProvider.isUnchanged,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),

                          if (typeWithSubFilters) ...[
                            AppDropdown<String>(
                              label: 'Category Group',
                              value: _provider.selectedCategory,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('All Categories')),
                                if (_provider.selectedType == 'product')
                                  ..._productCategories.map((c) => DropdownMenuItem(value: c['key'], child: Text(c['label']!))),
                                if (_provider.selectedType == 'property')
                                  ..._propertyCategories.map((c) => DropdownMenuItem(value: c['key'], child: Text(c['label']!))),
                                if (_provider.selectedType == 'lodge')
                                  ..._lodgeCategories.map((c) => DropdownMenuItem(value: c['key'], child: Text(c['label']!))),
                              ],
                              onChanged: (val) {
                                setSheetState(() {
                                  _selectedSubCategory = null;
                                  _selectedBrand = null;
                                });
                                _provider.updateFilters(
                                  category: val,
                                  district: SearchProvider.isUnchanged,
                                  listingPurpose: SearchProvider.isUnchanged,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Dynamic Cascading Subcategory Dropdown Panel (renders if product group is active)
                          if (_provider.selectedType == 'product' && _provider.selectedCategory != null && availableSubCategories.isNotEmpty) ...[
                            AppDropdown<String>(
                              label: 'Subcategory Selection',
                              value: availableSubCategories.contains(_selectedSubCategory) ? _selectedSubCategory : null,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('All Subcategories')),
                                ...availableSubCategories.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))),
                              ],
                              onChanged: (val) {
                                setSheetState(() {
                                  _selectedSubCategory = val;
                                  _selectedBrand = null;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          // Dynamic Cascading Brand Dropdown Panel (renders if subcategory is selected)
                          if (_provider.selectedType == 'product' && _selectedSubCategory != null && availableBrands.isNotEmpty) ...[
                            AppDropdown<String>(
                              label: 'Brand/Label Selection',
                              value: availableBrands.contains(_selectedBrand) ? _selectedBrand : null,
                              items: [
                                const DropdownMenuItem(value: null, child: Text('All Brands')),
                                ...availableBrands.map((b) => DropdownMenuItem(value: b, child: Text(b))),
                              ],
                              onChanged: (val) {
                                setSheetState(() {
                                  _selectedBrand = val;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          if (_provider.selectedType == 'property') ...[
                            AppDropdown<String>(
                              label: 'Listing Purpose',
                              value: _provider.selectedListingPurpose,
                              items: const [
                                DropdownMenuItem(value: null, child: Text('Any Purpose (Rent/Sale)')),
                                DropdownMenuItem(value: 'sale', child: Text('For Sale')),
                                DropdownMenuItem(value: 'rent', child: Text('For Rent')),
                              ],
                              onChanged: (val) {
                                _provider.updateFilters(
                                  listingPurpose: val,
                                  district: SearchProvider.isUnchanged,
                                  category: SearchProvider.isUnchanged,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            text: "Apply Active Filters",
                            fullWidth: true,
                            onPressed: () {
                              _provider.updateFilters(
                                district: SearchProvider.isUnchanged,
                                category: SearchProvider.isUnchanged,
                                listingPurpose: SearchProvider.isUnchanged,
                              );
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, child) {
        final isFilterActive = _provider.selectedDistrict != null || 
                               _provider.selectedCategory != null || 
                               _provider.selectedListingPurpose != null ||
                               _selectedSubCategory != null ||
                               _selectedBrand != null;

        final bool isProductTabOnly = _provider.selectedType == 'product';

        final List<SearchResultItem> productItems = _provider.results.where((e) => e.resultType == 'product').toList();
        final List<SearchResultItem> bannerItems = _provider.results.where((e) => e.resultType != 'product').toList();

        final double screenWidth = MediaQuery.of(context).size.width;

        int productColumns = 2;
        if (screenWidth >= 1200) productColumns = 6;
        else if (screenWidth >= 800) productColumns = 4;
        else if (screenWidth >= 600) productColumns = 3;

        int bannerColumns = 1;
        if (screenWidth >= 1200) bannerColumns = 4;
        else if (screenWidth >= 800) bannerColumns = 3;
        else if (screenWidth >= 600) bannerColumns = 2;

        return Column(
          children: [
            // 1. INPUT SEARCH BAR & ACTIONS FILTER BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search matching items...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _provider.updateFilters(query: '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary(context), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _showFilterBottomSheet,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: isFilterActive ? AppColors.mangoOrange.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFilterActive ? AppColors.mangoOrange : Colors.grey.shade300,
                          width: isFilterActive ? 1.6 : 1,
                        ),
                      ),
                      child: const Icon(Icons.tune_rounded),
                    ),
                  ),
                ],
              ),
            ),

            // 2. HORIZONTAL SCROLL CHIP TABS (Cleaned layout—stray Spacer removed)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _types.length,
                itemBuilder: (context, index) {
                  final type = _types[index];
                  final isSelected = _provider.selectedType == type['key'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(type['label']!),
                      selected: isSelected,
                      selectedColor: AppColors.primary(context).withOpacity(0.2),
                      checkmarkColor: AppColors.primary(context),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary(context) : AppColors.darkText,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedSubCategory = null;
                          _selectedBrand = null;
                        });
                        _provider.updateFilters(
                          type: type['key'],
                          district: SearchProvider.isUnchanged,
                          category: null,
                          listingPurpose: null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // 3. ADAPTIVE HYBRID SLIVER VIEW ENGINE
            Expanded(
              child: _provider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.mangoOrange))
                  : _provider.errorMessage.isNotEmpty
                      ? Center(child: Text(_provider.errorMessage, style: const TextStyle(color: Colors.red)))
                      : _provider.results.isEmpty
                          ? const Center(child: Text('No matching items found.'))
                          : RefreshIndicator(
                              onRefresh: () async => _provider.resetSearch(),
                              color: AppColors.mangoOrange,
                              child: CustomScrollView(
                                controller: _scrollController,
                                slivers: [
                                  // SECTION A: PRODUCT ITEMS
                                  if (isProductTabOnly || productItems.isNotEmpty)
                                    SliverPadding(
                                      padding: const EdgeInsets.all(12.0),
                                      sliver: SliverGrid(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: productColumns,
                                          childAspectRatio: 0.62,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            final item = isProductTabOnly ? _provider.results[index] : productItems[index];
                                            return _buildDynamicFeedCard(item);
                                          },
                                          childCount: isProductTabOnly ? _provider.results.length : productItems.length,
                                        ),
                                      ),
                                    ),

                                  // SECTION B: OTHER DOMAINS
                                  if (!isProductTabOnly && bannerItems.isNotEmpty)
                                    SliverPadding(
                                      padding: const EdgeInsets.all(12.0),
                                      sliver: SliverGrid(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: bannerColumns,
                                          childAspectRatio: bannerColumns == 1 ? 1.3 : 1.1,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                        ),
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) => _buildDynamicFeedCard(bannerItems[index]),
                                          childCount: bannerItems.length,
                                        ),
                                      ),
                                    ),

                                  if (_provider.isLoadingMore)
                                    const SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Center(child: CircularProgressIndicator(color: AppColors.mangoOrange)),
                                      ),
                                    ),
                                  const SliverToBoxAdapter(
                                    child: WebFooter(),
                                  ),
                                ],
                              ),
                            ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDynamicFeedCard(SearchResultItem item) {
    final String type = item.resultType ?? ''; 

    switch (type) {
      case 'product':
        final String fallbackImage = item.imageUrl ?? item.details['image'] ?? '';
        final product = Product(
          id: item.id,
          ownerId: item.details['owner'],
          shopId: item.details['shop'] ?? 0,
          shopName: item.details['shop_name'] ?? 'Market Shop', 
          shopDistrict: item.district,
          shopPhoneNumber: item.details['shop_phone_number']?.toString(),
          name: item.title,
          slug: item.details['slug'] ?? '',
          description: item.subtitle,
          image: fallbackImage.isNotEmpty ? fallbackImage : null,
          category: item.details['category'] ?? '',
          subCategory: item.details['sub_category'] ?? '', 
          brand: item.details['brand'] ?? '',             
          price: double.tryParse(item.price?.toString() ?? '0') ?? 0.0,
          originalPrice: item.details['original_price'] != null 
              ? double.tryParse(item.details['original_price'].toString()) 
              : null,
          discountPercentage: item.details['discount_percentage'] ?? 0,
          stock: item.details['stock'] ?? 0,
          sku: item.details['sku'] ?? '',
          isActive: item.details['is_active'] ?? true,
          rating: double.tryParse(item.details['rating']?.toString() ?? '0') ?? 0.0,
          totalReviews: item.details['total_reviews'] ?? 0,
          createdAt: DateTime.tryParse(item.details['created_at'] ?? '') ?? DateTime.now(),
          images: fallbackImage.isNotEmpty ? [fallbackImage] : const [],
          variants: const [],
        );
        return ProductCard(product: product);

      case 'shop':
        final shop = Shop(
          id: item.id,
          name: item.title,
          slug: item.details['slug'] ?? '',
          description: item.subtitle,
          logo: item.details['logo'] ?? '',
          banner: item.imageUrl ?? item.details['banner'],
          category: item.details['category'] ?? '',
          latitude: double.tryParse(item.details['latitude']?.toString() ?? '0') ?? 0.0,
          longitude: double.tryParse(item.details['longitude']?.toString() ?? '0') ?? 0.0,
          address: item.details['address'] ?? '',
          city: item.city ?? '',
          district: item.district ?? '',
          phoneNumber: item.details['phone_number'] ?? '',
          email: item.details['email'] ?? '',
          status: item.details['status'] ?? 'pending',
          isActive: item.details['is_active'] ?? false,
          rating: double.tryParse(item.details['rating']?.toString() ?? '0') ?? 0.0,
          totalReviews: item.details['total_reviews'] ?? 0,
          createdAt: DateTime.tryParse(item.details['created_at'] ?? '') ?? DateTime.now(),
          productCount: item.details['product_count'], 
        );
        return ShopCard(shop: shop);

      case 'property':
        final String mainImage = item.imageUrl ?? item.details['image'] ?? '';
        final propertyImages = mainImage.isNotEmpty 
            ? [PropertyImage(id: 0, image: mainImage, isPrimary: true)] 
            : <PropertyImage>[];

        final property = Property(
          id: item.id,
          ownerId: item.details['owner'] ?? 0,
          title: item.title,
          slug: item.details['slug'] ?? '',
          description: item.subtitle,
          listingPurpose: item.details['listing_purpose'] ?? 'sale',
          propertyType: item.details['property_type'] ?? 'house',
          status: item.details['status'] ?? 'available',
          latitude: double.tryParse(item.details['latitude']?.toString() ?? '0') ?? 0.0,
          longitude: double.tryParse(item.details['longitude']?.toString() ?? '0') ?? 0.0,
          address: item.details['address'] ?? '',
          city: item.city ?? '',
          district: item.district ?? '',
          bedrooms: item.details['bedrooms'],
          bathrooms: item.details['bathrooms'],
          sizeSqm: double.tryParse(item.details['size_sqm']?.toString() ?? '0') ?? 0.0,
          price: double.tryParse(item.price?.toString() ?? '0') ?? 0.0,
          currency: item.details['currency'] ?? 'MWK',
          isPubliclyVisible: item.details['is_publicly_visible'] ?? true,
          unlockFee: double.tryParse(item.details['unlock_fee']?.toString() ?? '0') ?? 50.0,
          viewCount: item.details['view_count'] ?? 0,
          images: propertyImages,
          ownerName: item.details['owner_name'] ?? '',
          ownerPhoneNumber: item.details['owner_phone_number']?.toString(),
          isUnlocked: item.details['is_unlocked'] ?? false,
          createdAt: DateTime.tryParse(item.details['created_at'] ?? '') ?? DateTime.now(), // 👈 ADD THIS LINE HERE
        );
        return PropertyCard(property: property);

      case 'event':
        final event = EventModel(
          id: item.id,
          title: item.title,
          description: item.subtitle,
          venue: item.details['venue'] ?? '',
          district: item.district ?? '',
          city: item.city ?? '',
          latitude: double.tryParse(item.details['latitude']?.toString() ?? ''),
          longitude: double.tryParse(item.details['longitude']?.toString() ?? ''),
          eventDate: item.details['event_date'] ?? '',
          startTime: item.details['start_time'] ?? '00:00:00',
          endTime: item.details['end_time'] ?? '00:00:00',
          banner: item.imageUrl ?? item.details['banner'] ?? '',
          ticketPrice: double.tryParse(item.details['regular_ticket_price']?.toString() ?? '0') ?? 0.0,
          totalTickets: int.tryParse(item.details['total_tickets']?.toString() ?? '0') ?? 0,
          availableTickets: int.tryParse(item.details['tickets_remaining']?.toString() ?? '0') ?? 0,
          isFeatured: item.details['is_featured'] ?? false,
          organizerPhoneNumber: item.details['organizer_phone_number']?.toString(),
          ticketTypes: const [],
        );
        return EventCard(event: event);

      case 'lodge':
        final List<String> lodgeImages = [];
        if (item.imageUrl != null) {
          lodgeImages.add(item.imageUrl!);
        } else if (item.details['banner'] != null) {
          lodgeImages.add(item.details['banner']);
        }

        final lodge = Lodge(
          id: item.id,
          name: item.title,
          description: item.subtitle,
          lodgeType: item.details['lodge_type'] ?? 'Lodge',
          city: item.city ?? '',
          district: item.district ?? '',
          address: item.details['address'] ?? item.city ?? '',
          phoneNumber: item.details['phone_number'] ?? '',
          email: item.details['email'] ?? '',
          isVerified: item.details['is_verified'] ?? false,
          images: lodgeImages,
          latitude: double.tryParse(item.details['latitude']?.toString() ?? ''),
          longitude: double.tryParse(item.details['longitude']?.toString() ?? ''),
          ownerId: item.details['owner_id'] ?? item.details['owner'],
          ownerPhoneNumber: item.details['owner_phone_number']?.toString(),
        );
        return LodgeCard(lodge: lodge);

      default:
        return const SizedBox.shrink();
    }
  }
}