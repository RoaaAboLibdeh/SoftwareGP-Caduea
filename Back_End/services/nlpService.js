const natural = require('natural');
const classifier = new natural.BayesClassifier();
const Product = require('../models/Product');

// ====================== TRAINING DATA ======================
// Recipient-based training
const recipientTraining = [
  { text: 'gift for mom', label: 'gift.suggestion.mother' },
  { text: 'present for mother', label: 'gift.suggestion.mother' },
  { text: 'something for my mom', label: 'gift.suggestion.mother' },
  
  { text: 'gift for dad', label: 'gift.suggestion.father' },
  { text: 'present for father', label: 'gift.suggestion.father' },
  
  { text: 'gift for wife', label: 'gift.suggestion.wife' },
  { text: 'present for my wife', label: 'gift.suggestion.wife' },
  
  { text: 'gift for husband', label: 'gift.suggestion.husband' },
  { text: 'present for my husband', label: 'gift.suggestion.husband' },
  
  { text: 'gift for girlfriend', label: 'gift.suggestion.girlfriend' },
  { text: 'present for my girlfriend', label: 'gift.suggestion.girlfriend' },
  
  { text: 'gift for boyfriend', label: 'gift.suggestion.boyfriend' },
  { text: 'present for my boyfriend', label: 'gift.suggestion.boyfriend' },
  
  { text: 'gift for child', label: 'gift.suggestion.child' },
  { text: 'present for kid', label: 'gift.suggestion.child' },
  
  { text: 'gift for teen', label: 'gift.suggestion.teen' },
  { text: 'present for teenager', label: 'gift.suggestion.teen' },
  
  { text: 'gift for friend', label: 'gift.suggestion.friend' },
  { text: 'present for my friend', label: 'gift.suggestion.friend' },
  
  { text: 'gift for colleague', label: 'gift.suggestion.colleague' },
  { text: 'present for coworker', label: 'gift.suggestion.colleague' }
];

// Occasion-based training
const occasionTraining = [
  { text: 'birthday gift', label: 'gift.suggestion.birthday' },
  { text: 'present for birthday', label: 'gift.suggestion.birthday' },
  
  { text: 'anniversary gift', label: 'gift.suggestion.anniversary' },
  { text: 'present for anniversary', label: 'gift.suggestion.anniversary' },
  
  { text: 'wedding gift', label: 'gift.suggestion.wedding' },
  { text: 'present for wedding', label: 'gift.suggestion.wedding' },
  
  { text: 'valentine gift', label: 'gift.suggestion.valentine' },
  { text: 'present for valentines day', label: 'gift.suggestion.valentine' },
  
  { text: 'christmas gift', label: 'gift.suggestion.christmas' },
  { text: 'holiday present', label: 'gift.suggestion.christmas' },
  
  { text: 'graduation gift', label: 'gift.suggestion.graduation' },
  { text: 'present for graduation', label: 'gift.suggestion.graduation' },
  
  { text: 'mothers day gift', label: 'gift.suggestion.mothersday' },
  { text: 'fathers day present', label: 'gift.suggestion.fathersday' },
  
  { text: 'just because gift', label: 'gift.suggestion.justbecause' },
  { text: 'no occasion present', label: 'gift.suggestion.justbecause' }
];

// Category-based training
const categoryTraining = [
  { text: 'electronics gift', label: 'gift.category.electronics' },
  { text: 'tech present', label: 'gift.category.electronics' },
  
  { text: 'jewelry gift', label: 'gift.category.jewelry' },
  { text: 'present jewelry', label: 'gift.category.jewelry' },
  
  { text: 'home decor gift', label: 'gift.category.homedecor' },
  { text: 'present for home', label: 'gift.category.homedecor' },
  
  { text: 'fashion gift', label: 'gift.category.fashion' },
  { text: 'clothing present', label: 'gift.category.fashion' },
  
  { text: 'toy gift', label: 'gift.category.toys' },
  { text: 'present toy', label: 'gift.category.toys' },
  
  { text: 'experience gift', label: 'gift.category.experiences' },
  { text: 'present experience', label: 'gift.category.experiences' },
  
  { text: 'personalized gift', label: 'gift.category.personalized' },
  { text: 'custom present', label: 'gift.category.personalized' },
  
  { text: 'book gift', label: 'gift.category.books' },
  { text: 'present book', label: 'gift.category.books' },
  
  { text: 'beauty gift', label: 'gift.category.beauty' },
  { text: 'cosmetic present', label: 'gift.category.beauty' }
];

// Price-based training
const priceTraining = [
  { text: 'cheap gift', label: 'gift.price.cheap' },
  { text: 'inexpensive present', label: 'gift.price.cheap' },
  
  { text: 'affordable gift', label: 'gift.price.affordable' },
  { text: 'reasonable present', label: 'gift.price.affordable' },
  
  { text: 'luxury gift', label: 'gift.price.luxury' },
  { text: 'expensive present', label: 'gift.price.luxury' },
  
  { text: 'gift under $50', label: 'gift.price.under50' },
  { text: 'present below 50 dollars', label: 'gift.price.under50' },
  
  { text: 'gift under $100', label: 'gift.price.under100' },
  { text: 'present below 100 dollars', label: 'gift.price.under100' }
];

// Combined training (recipient + occasion + category)
const combinedTraining = [
  { text: 'birthday gift for mom', label: 'gift.suggestion.mother.birthday' },
  { text: 'jewelry for wife', label: 'gift.suggestion.wife.jewelry' },
  { text: 'tech gift for boyfriend', label: 'gift.suggestion.boyfriend.electronics' },
  { text: 'affordable gift for colleague', label: 'gift.suggestion.colleague.affordable' },
  { text: 'luxury watch for husband', label: 'gift.suggestion.husband.luxury.electronics' },
  { text: 'personalized gift for father', label: 'gift.suggestion.father.personalized' }
];

// General gift requests
const generalTraining = [
  { text: 'help me choose a gift', label: 'gift.help' },
  { text: 'what do you recommend', label: 'gift.help' },
  { text: 'suggest something nice', label: 'gift.help' },
  { text: 'I need gift ideas', label: 'gift.help' }
];

// Social interactions
const socialTraining = [
  { text: 'hi', label: 'greeting' },
  { text: 'hello', label: 'greeting' },
  { text: 'hey', label: 'greeting' },
  { text: 'thank you', label: 'appreciation' },
  { text: 'thanks', label: 'appreciation' }
];

// Combine all training data
const allTraining = [
  ...recipientTraining,
  ...occasionTraining,
  ...categoryTraining,
  ...priceTraining,
  ...combinedTraining,
  ...generalTraining,
  ...socialTraining
];

// Add to classifier
allTraining.forEach(item => {
  classifier.addDocument(item.text, item.label);
});

// Train the classifier
classifier.train();

// ====================== ENTITY EXTRACTION ======================
const giftEntities = {
  recipient: ['mother', 'father', 'wife', 'husband', 'girlfriend', 'boyfriend', 'child', 'teen', 'friend', 'colleague'],
  occasion: ['birthday', 'anniversary', 'wedding', 'valentine', 'christmas', 'graduation', 'mothers day', 'fathers day', 'just because'],
  category: ['electronics', 'jewelry', 'home decor', 'fashion', 'toys', 'experiences', 'personalized', 'books', 'beauty'],
  price: ['cheap', 'affordable', 'luxury', 'expensive', 'under 50', 'under 100']
};

function extractFiltersFromMessage(message) {
  const filters = {};
  const lowerMsg = message.toLowerCase();

  // Price extraction
  if (lowerMsg.includes('cheap') || lowerMsg.includes('inexpensive')) {
    filters.price = 'cheap';
    filters.maxPrice = 25;
  } else if (lowerMsg.includes('affordable') || lowerMsg.includes('reasonable')) {
    filters.price = 'affordable';
    filters.maxPrice = 50;
  } else if (lowerMsg.includes('luxury') || lowerMsg.includes('expensive')) {
    filters.price = 'luxury';
    filters.minPrice = 100;
  }
  
  // Exact price extraction
  const priceMatch = lowerMsg.match(/(under|below|less than) (\$|€|£)?(\d+)/);
  if (priceMatch) {
    filters.maxPrice = Number(priceMatch[3]);
  }

  // Recipient extraction
  giftEntities.recipient.forEach(recipient => {
    if (lowerMsg.includes(recipient)) filters.recipient = recipient;
  });

  // Occasion extraction
  giftEntities.occasion.forEach(occasion => {
    if (lowerMsg.includes(occasion)) filters.occasion = occasion;
  });

  // Category extraction
  giftEntities.category.forEach(category => {
    if (lowerMsg.includes(category)) filters.category = category;
  });

  // Keyword extraction (from product schema)
  const keywords = [];
  if (lowerMsg.includes('watch') || lowerMsg.includes('smartwatch')) keywords.push('watch');
  if (lowerMsg.includes('ring') || lowerMsg.includes('necklace')) keywords.push('jewelry');
  if (lowerMsg.includes('book') || lowerMsg.includes('novel')) keywords.push('book');
  if (keywords.length) filters.keywords = keywords;

  return filters;
}

// ====================== GIFT RECOMMENDATIONS ======================
async function getGiftRecommendations(filters) {
  const query = {};
  
  // Map filters to product schema fields
  if (filters.recipient) query.recipientType = filters.recipient;
  if (filters.occasion) query.occasion = filters.occasion;
  if (filters.category) query.category = filters.category;
  if (filters.keywords) query.$text = { $search: filters.keywords.join(' ') };
  
  // Price filtering
  if (filters.maxPrice) {
    query.price = { ...query.price, $lte: filters.maxPrice };
  }
  if (filters.minPrice) {
    query.price = { ...query.price, $gte: filters.minPrice };
  }

  return await Product.find(query)
    .sort({ popularity: -1 })
    .limit(5)
    .select('name price description productUrl imageUrls');
}

// ====================== RESPONSE GENERATION ======================
async function generateResponse(intent, filters, products) {
  // Cute responses for social interactions
  const cuteResponses = {
    'greeting': [
      "Hello there! *waves* How can I help you find the perfect gift today?",
      "Hi friend! *smiles* Looking for gift ideas? I'd love to help!",
      "Hiiii! *excited* Ready to find something special for someone special?"
    ],
    'appreciation': [
      "You're so welcome! *happy dance* It was my pleasure to help!",
      "Aww, thanks! *blushes* Let me know if you need more recommendations!",
      "My pleasure! *beams* Happy gift-giving!"
    ],
    'gift.help': [
      "Of course! *claps* Let's find something wonderful together!",
      "I'd love to help! *thinking* Tell me more about who it's for.",
      "Yay! *excited* Gift shopping is my favorite! What's the occasion?"
    ]
  };

  // Return cute response if available
  if (cuteResponses[intent]) {
    return cuteResponses[intent][Math.floor(Math.random() * cuteResponses[intent].length)];
  }

  // Handle no products found
  if (!products.length) {
    const fallbacks = [
      "Hmm, I couldn't find perfect matches *thinking*, but here are some popular gifts:",
      "Let me think... *taps chin* These might work well:",
      "I searched high and low! *determined* Here are some great options:"
    ];
    const fallback = fallbacks[Math.floor(Math.random() * fallbacks.length)];
    
    const popularProducts = await Product.find()
      .sort({ popularity: -1 })
      .limit(3)
      .select('name price productUrl');
    
    return fallback + "\n" + 
      popularProducts.map(p => 
        `- ${p.name} ($${p.price}) [View](${p.productUrl || '#'})`
      ).join('\n');
  }

  // Recipient-specific responses
  const recipientResponses = {
    'mother': [
      "For your amazing mom *heart* I recommend these thoughtful gifts:",
      "Mothers deserve the best! *nod* Here are some wonderful options:",
      "What a wonderful child you are! *smile* For your mom:"
    ],
    'father': [
      "For your awesome dad *thumbs up* These would make great gifts:",
      "Fathers work so hard! *appreciative* Here are my top picks:",
      "Your dad will love these thoughtful presents:"
    ],
    'wife': [
      "For your lovely wife *sparkles* I found these special items:",
      "Wives appreciate thoughtful gifts! *smile* Consider these:",
      "She'll adore these carefully selected gifts:"
    ],
    'husband': [
      "For your wonderful husband *muscle* These would be great:",
      "Husbands can be tricky to shop for! *thinking* Try these:",
      "He'll be thrilled with these options:"
    ],
    'girlfriend': [
      "For your sweet girlfriend *heart eyes* I recommend these:",
      "She'll love these romantic gifts! *blush* Here are my picks:",
      "Thoughtful gifts for your special someone:"
    ],
    'boyfriend': [
      "For your awesome boyfriend *thumbs up* These would work well:",
      "Guys love these kinds of gifts! *nod* Consider these:",
      "He'll appreciate these thoughtful presents:"
    ],
    'child': [
      "For the little one *teddy bear* These would make perfect gifts:",
      "Kids will love these fun presents! *excited* Here are my picks:",
      "Perfect gifts to put a smile on a child's face:"
    ],
    'teen': [
      "For the teenager *smartphone* These cool gifts would work well:",
      "Teens can be picky! *thinking* But they'll like these:",
      "Trendy gifts perfect for any teen:"
    ],
    'friend': [
      "For your wonderful friend *happy* I recommend these:",
      "Friends deserve the best! *cheer* Here are great options:",
      "These would make perfect gifts for your friend:"
    ],
    'colleague': [
      "For your colleague *handshake* These professional gifts would work well:",
      "Office-appropriate gift ideas! *nod* Here are my suggestions:",
      "These would make great workplace gifts:"
    ]
  };

  // Occasion-specific responses
  const occasionResponses = {
    'birthday': [
      "For this special birthday *party* I recommend these:",
      "Birthdays call for great gifts! *celebrate* Here are my picks:",
      "Make their birthday extra special with these:"
    ],
    'anniversary': [
      "For your anniversary *heart* These romantic gifts would be perfect:",
      "Celebrate your love with these special gifts:",
      "Anniversary gifts to cherish your time together:"
    ],
    'wedding': [
      "For the happy couple *rings* These wedding gifts would be perfect:",
      "Celebrate their union with these special presents:",
      "Thoughtful gifts for the newlyweds:"
    ],
    'valentine': [
      "For Valentine's Day *heart* These romantic gifts would be perfect:",
      "Show your love with these special Valentine's presents:",
      "Sweet gifts to express your affection:"
    ],
    'christmas': [
      "For Christmas *tree* These festive gifts would be perfect:",
      "Spread holiday cheer with these Christmas presents:",
      "Thoughtful gifts for the holiday season:"
    ],
    'graduation': [
      "For this big achievement *cap* These meaningful gifts would work well:",
      "Celebrate their success with these graduation gifts:",
      "Perfect gifts to commemorate this milestone:"
    ],
    'mothersday': [
      "For Mother's Day *flower* These loving gifts would be perfect:",
      "Show your appreciation with these Mother's Day presents:",
      "Thoughtful gifts to honor mom this Mother's Day:"
    ],
    'fathersday': [
      "For Father's Day *tools* These awesome gifts would be perfect:",
      "Show your love with these Father's Day presents:",
      "Great gifts to celebrate dad this Father's Day:"
    ],
    'justbecause': [
      "For no special reason *smile* These thoughtful gifts would work well:",
      "Just because gifts to show you care:",
      "Perfect presents to brighten someone's day:"
    ]
  };

  // Extract base intent parts
  const intentParts = intent.split('.');
  const recipient = intentParts.find(part => recipientResponses[part]);
  const occasion = intentParts.find(part => occasionResponses[part]);

  // Build response
  let response = "I found some great options for you:";
  
  if (recipient && occasion) {
    const recipientRes = recipientResponses[recipient][Math.floor(Math.random() * recipientResponses[recipient].length)];
    const occasionRes = occasionResponses[occasion][Math.floor(Math.random() * occasionResponses[occasion].length)];
    response = `${recipientRes} ${occasionRes}`;
  } else if (recipient) {
    response = recipientResponses[recipient][Math.floor(Math.random() * recipientResponses[recipient].length)];
  } else if (occasion) {
    response = occasionResponses[occasion][Math.floor(Math.random() * occasionResponses[occasion].length)];
  }

  // Format products with links and images
  return response + "\n" +
    products.map(p => {
      let productText = `- ${p.name} ($${p.price})`;
      if (p.description) productText += `: ${p.description.substring(0, 60)}...`;
      if (p.productUrl) productText += ` [View Product](${p.productUrl})`;
      return productText;
    }).join('\n');
}

// ====================== EXPORTS ======================
module.exports = {
  classify: classifier.classify.bind(classifier),
  extractFiltersFromMessage,
  getGiftRecommendations,
  generateResponse
};