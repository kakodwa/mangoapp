import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// Project Imports
import '../../providers/products_provider.dart';
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart';
import '../../widgets/image_crop_picker.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/web_footer.dart';
import '../../utils/app_toast.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_text_field.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final shopNameController = TextEditingController(text: 'shop');

  // ======================
  // VARIANT CONTROLLERS & STATE
  // ======================
  List<LocalProductVariant> variants = [];
  final variantWholesalePriceController = TextEditingController();
  final variantWeightController = TextEditingController();
  final variantStockController = TextEditingController();
  final Map<String, TextEditingController> dynamicAttributeControllers = {};

  bool isActive = true;
  bool isLoading = false;

  // Selected state options
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedBrand;
  String selectedDelivery = '1 - 2 Business Days'; // 👈 Added

  // Predefined delivery timeframe options
  final List<String> deliveryOptions = [
    'Within 24 Hours',
    '1 - 2 Business Days',
    '3 - 5 Business Days',
    '1 - 2 Weeks (Imported)',
  ];

  // Primary list of master categories
  final List<String> categories = [
    "Electronics",
    "Groceries",
    "Fashion",
    "Home & Living",
    "Beauty & Personal Care",
    "Health & Wellness",
    "Agriculture",
    "Vehicles",
    "Construction & Hardware",
    "Books & Education",
    "Sports & Outdoors",
    "Baby & Kids",
    "Food & Beverages",
    "Pets & Animals",
    "Office Supplies",
    "Entertainment",
    "Services",
    "Industrial Equipment",
  ];

  // Cascading structural mapping definitions
  final Map<String, Map<String, List<String>>> categorySubCategoryBrands = {
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

  final Map<String, List<String>> categoryFields = {
    'Fashion': ['Color', 'Size', 'Material'],
    'Electronics': ['Color', 'Storage', 'RAM'],
    'Groceries': ['Weight', 'Pack Size'],
    'Vehicles': ['Color', 'Transmission', 'Engine'],
    'Agriculture': ['Weight', 'Variety'],
    'Books & Education': ['Format', 'Language'],
    'Food & Beverages': ['Weight', 'Flavor'],
  };

  List<XFile> images = [];

  void _showAddVariantDialog(List<String> fields) {
    variantWholesalePriceController.clear();
    variantWeightController.clear();
    variantStockController.clear();

    for (var controller in dynamicAttributeControllers.values) {
      controller.dispose();
    }
    dynamicAttributeControllers.clear();
    
    for (var field in fields) {
      dynamicAttributeControllers[field] = TextEditingController();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AlertDialog(
              title: Text("Add ${selectedCategory ?? ''} Variant"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: variantStockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Stock Quantity *"),
                    ),
                    TextField(
                      controller: variantWholesalePriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Wholesale Price (\$)"),
                    ),
                    TextField(
                      controller: variantWeightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Weight (Grams)"),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Divider(),
                    ),
                    Text(
                      "Category attributes", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...fields.map((fieldName) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: dynamicAttributeControllers[fieldName],
                          decoration: InputDecoration(
                            labelText: fieldName,
                            hintText: "Enter $fieldName",
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final Map<String, dynamic> collectedAttributes = {};
                    dynamicAttributeControllers.forEach((key, controller) {
                      if (controller.text.trim().isNotEmpty) {
                        collectedAttributes[key] = controller.text.trim();
                      }
                    });

                    if (variantStockController.text.trim().isEmpty) {
                      AppToast.error(context, "Stock quantity is required for variants.");
                      return;
                    }

                    if (collectedAttributes.isEmpty) {
                      AppToast.error(context, "Please complete at least one category specification.");
                      return;
                    }

                    setState(() {
                      variants.add(
                        LocalProductVariant(
                          sku: null,
                          stock: int.tryParse(variantStockController.text) ?? 0,
                          wholesalePrice: double.tryParse(variantWholesalePriceController.text) ?? 0.0,
                          weightG: int.tryParse(variantWeightController.text) ?? 0,
                          attributes: collectedAttributes,
                        ),
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Add Variant"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      AppToast.error(context, 'Please select category');
      return;
    }

    if (images.isEmpty) {
      AppToast.error(context, 'Please upload at least one image for this product.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final product = Product(
        id: 0,
        shopId: 1,
        shopName: shopNameController.text.trim(),
        name: nameController.text,
        slug: nameController.text
            .trim()
            .toLowerCase()
            .replaceAll(' ', '-'),
        description: descriptionController.text,
        image: null,
        category: selectedCategory!,
        subCategory: selectedSubCategory ?? '', 
        brand: selectedBrand ?? '',             
        deliveryDuration: selectedDelivery, // 👈 Added
        price: double.parse(priceController.text),
        originalPrice: null,
        discountPercentage: 0,
        stock: int.parse(stockController.text),
        sku: "",
        isActive: isActive,
        rating: 0.0,
        totalReviews: 0,
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(productActionsProvider)
          .createProduct(
            product,
            images.first, 
            variants, 
          );

      await ref
          .read(productActionsProvider)
          .uploadProductImages(
            created.id,
            images,
          );

      ref.invalidate(productsProvider);

      if (mounted) {
        AppToast.success(
          context,
          "Product created successfully",
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          "Error: ${e.toString()}",
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    shopNameController.dispose();
    variantWholesalePriceController.dispose();
    variantWeightController.dispose();
    variantStockController.dispose();
    for (var controller in dynamicAttributeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final contentPadding = isDesktop 
        ? EdgeInsets.symmetric(horizontal: screenWidth * 0.15, vertical: AppSpacing.lg)
        : const EdgeInsets.all(AppSpacing.md);

    // Dynamic cascade filters setup
    final Map<String, List<String>>? activeSubCategoryData = categorySubCategoryBrands[selectedCategory];
    final List<String> availableSubCategories = activeSubCategoryData?.keys.toList() ?? [];
    final List<String> availableBrands = (selectedSubCategory != null && activeSubCategoryData != null)
        ? (activeSubCategoryData[selectedSubCategory] ?? [])
        : [];

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flex(
                        direction: isDesktop ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: isDesktop ? 3 : 0,
                            child: Column(
                              children: [
                                AppTextField(
                                  label: 'Product Name',
                                  hint: 'Enter product name',
                                  controller: nameController,
                                  type: TextFieldType.text,
                                  isRequired: true,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Product name is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppTextField(
                                  label: 'Description',
                                  hint: 'Enter product description',
                                  controller: descriptionController,
                                  type: TextFieldType.multiline,
                                  maxLines: 4,
                                  isRequired: true,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Description is required';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          if (isDesktop) const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            flex: isDesktop ? 2 : 0,
                            child: Column(
                              children: [
                                if (!isDesktop) const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Price',
                                        hint: '0.00',
                                        controller: priceController,
                                        type: TextFieldType.number,
                                        isRequired: true,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Price required';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'Invalid price';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: AppTextField(
                                        label: 'Stock',
                                        hint: '0',
                                        controller: stockController,
                                        type: TextFieldType.number,
                                        isRequired: true,
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Stock required';
                                          }
                                          if (int.tryParse(value) == null) {
                                            return 'Invalid stock';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      // 1. Primary Category Dropdown Selection Box
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category *',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            selectedSubCategory = null; // Auto reset subcategory
                            selectedBrand = null;       // Auto reset brand
                            variants.clear(); 
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select category';
                          }
                          return null;
                        },
                      ),
                      
                      // 2. Dynamic Subcategory Dropdown Panel (renders only if category has subcategories)
                      if (selectedCategory != null && availableSubCategories.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          value: selectedSubCategory,
                          decoration: InputDecoration(
                            labelText: 'Subcategory *',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: availableSubCategories.map((sub) {
                            return DropdownMenuItem(
                              value: sub,
                              child: Text(sub),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSubCategory = value;
                              selectedBrand = null; // Reset brand when subcategory changes
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a subcategory';
                            }
                            return null;
                          },
                        ),
                      ],

                      // 3. Dynamic Brand Dropdown Panel (renders only if subcategory is selected and has brands)
                      if (selectedSubCategory != null && availableBrands.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        DropdownButtonFormField<String>(
                          value: selectedBrand,
                          decoration: InputDecoration(
                            labelText: 'Brand *',
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: availableBrands.map((b) {
                            return DropdownMenuItem(
                              value: b,
                              child: Text(b),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBrand = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a brand';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: AppSpacing.md),

                      // 4. Delivery Duration Field Dropdown Panel 👈 Added
                      DropdownButtonFormField<String>(
                        value: selectedDelivery,
                        decoration: InputDecoration(
                          labelText: 'Estimated Delivery Time *',
                          prefixIcon: const Icon(Icons.local_shipping_outlined),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: deliveryOptions.map((opt) {
                          return DropdownMenuItem(
                            value: opt,
                            child: Text(opt),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDelivery = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a delivery duration';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        "Product Images (Max 4 - Required *)",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 14),
                      ImageCropPicker(
                        maxImages: 4,
                        cropType: CropShapeType.square,
                        initialImages: images,
                        onChanged: (value) {
                          setState(() {
                            images = value;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Product Variants",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add Variant"),
                            onPressed: selectedCategory == null || !categoryFields.containsKey(selectedCategory)
                                ? null 
                                : () => _showAddVariantDialog(categoryFields[selectedCategory]!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (selectedCategory == null)
                        const Text(
                          "Choose a product category above to manage variations.", 
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        )
                      else if (!categoryFields.containsKey(selectedCategory))
                        const Text(
                          "Item configurations are not mapped for this category.", 
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        )
                      else if (variants.isEmpty)
                        const Text(
                          "No configuration items configured yet (Optional).", 
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        )
                      else
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: List.generate(variants.length, (index) {
                            final variant = variants[index];
                            final attrsText = variant.attributes.entries
                                .map((e) => '${e.key}: ${e.value}')
                                .join(', ');
                            return SizedBox(
                              width: isDesktop ? (screenWidth * 0.7 / 2) - 12 : double.infinity,
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: ListTile(
                                  title: Text("Stock: ${variant.stock} | SKU: ${variant.sku ?? 'Auto'}"),
                                  subtitle: Text("Specs: $attrsText\nWholesale: \$${variant.wholesalePrice}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => setState(() => variants.removeAt(index)),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: SwitchListTile(
                          value: isActive,
                          title: const Text("Product Active"),
                          subtitle: const Text("Visible to customers"),
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Theme.of(context).colorScheme.surface,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "Create Product",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDesktop) const WebFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}