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
  { text: 'hi there', label: 'greeting' },
  { text: 'hello!', label: 'greeting' },
  { text: 'good morning', label: 'greeting' },
  { text: 'good afternoon', label: 'greeting' },
  { text: 'greetings', label: 'greeting' },
  { text: 'howdy', label: 'greeting' },
  { text: 'thank you', label: 'appreciation' },
  { text: 'thanks', label: 'appreciation' },
  { text: 'thank you!', label: 'appreciation' },
  { text: 'thanks!', label: 'appreciation' },
  { text: 'appreciate it', label: 'appreciation' },
  { text: 'many thanks', label: 'appreciation' }
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
try {
  allTraining.forEach(item => {
    classifier.addDocument(item.text, item.label);
  });
  
  // Train the classifier
  classifier.train();
  
  console.log('Classifier trained successfully with', allTraining.length, 'examples');
  
  // Test basic classification
  console.log('Test classification "hello":', classifier.classify('hello')); // Should return 'greeting'
  console.log('Test classification "gift for mom":', classifier.classify('gift for mom')); // Should return 'gift.suggestion.mother'
} catch (error) {
  console.error('Error during classifier training:', error);
  throw error; // Fail fast during initialization
}

// ====================== ENHANCED CLASSIFICATION ======================
function classifyMessage(message) {
  try {
    if (!message || typeof message !== 'string' || message.trim().length === 0) {
      return 'unknown';
    }
    
    const result = classifier.classify(message.toLowerCase());
    console.log(`Classified "${message}" as:`, result); // Debug logging
    
    // Fallback for unknown messages
    return result !== 'none' ? result : 'unknown';
  } catch (error) {
    console.error('Classification error:', error);
    return 'unknown';
  }
}

// ====================== SIMPLE RESPONSE GENERATION ======================
function generateSimpleResponse(intent) {
  const responses = {
    'greeting': [
      "Hello there! How can I help you find the perfect gift today?",
      "Hi! I'm your gift assistant. Who are you shopping for?",
      "Welcome! Let's find a wonderful gift together."
    ],
    'appreciation': [
      "You're welcome! Happy to help!",
      "My pleasure! Let me know if you need more suggestions.",
      "Glad I could help!"
    ],
    'unknown': [
      "I'm not sure I understand. Could you tell me more about who you're shopping for?",
      "I'd love to help with gift ideas! Who is the gift for?",
      "Let's find a great gift! Could you tell me more about the occasion?"
    ]
  };
 // Add basic gift responses
  if (intent.startsWith('gift.suggestion.')) {
    return "I have some great gift ideas for you! Let me check...";
  }

  const category = intent.split('.')[0];
  const availableResponses = responses[category] || responses.unknown;
  return availableResponses[Math.floor(Math.random() * availableResponses.length)];
}

// ====================== MAIN PROCESSING FUNCTION ======================
async function processMessage(message) {
  try {
    // Step 1: Classify the message
    const intent = classifyMessage(message);
    
    // Step 2: Generate appropriate response
    const response = generateSimpleResponse(intent);
    
    return {
      success: true,
      intent,
      response
    };
  } catch (error) {
    console.error('Error processing message:', error);
    return {
      success: false,
      error: 'Sorry, I encountered an error. Please try again.'
    };
  }
}

function levenshteinDistance(a, b) {
  const matrix = Array.from({ length: b.length + 1 }, (_, i) => [i]);
  for (let i = 0; i <= a.length; i++) matrix[0][i] = i;

  for (let i = 1; i <= b.length; i++) {
    for (let j = 1; j <= a.length; j++) {
      const cost = a[j - 1] === b[i - 1] ? 0 : 1;
      matrix[i][j] = Math.min(
        matrix[i - 1][j] + 1,     // deletion
        matrix[i][j - 1] + 1,     // insertion
        matrix[i - 1][j - 1] + cost // substitution
      );
    }
  }

  return matrix[b.length][a.length];
}

// ====================== ENTITY EXTRACTION ======================
const giftEntities = {
  recipient: ['mother', 'father', 'wife', 'husband', 'girlfriend', 'boyfriend', 'child', 'teen', 'friend', 'colleague', 'parents', 'grandparents', 'siblings'],
  occasion: ['birthday', 'anniversary', 'wedding', 'valentine', 'christmas', 'graduation', 'mothers day', 'fathers day', 'just because', 'new year', 'baby shower'],
  category: ['electronics', 'jewelry', 'home decor', 'fashion', 'toys', 'experiences', 'personalized', 'books', 'beauty', 'kitchen', 'fitness', 'travel'],
  price: ['cheap', 'affordable', 'luxury', 'expensive', 'under 50', 'under 100', 'under 200', 'budget', 'premium']
};

function extractFiltersFromMessage(message) {
  const filters = {};
  const lowerMsg = message.toLowerCase();

  // Enhanced price extraction
  if (lowerMsg.includes('cheap') || lowerMsg.includes('inexpensive') || lowerMsg.includes('low cost')) {
    filters.price = 'cheap';
    filters.maxPrice = 25;
  } else if (lowerMsg.includes('affordable') || lowerMsg.includes('reasonable') || lowerMsg.includes('mid-range')) {
    filters.price = 'affordable';
    filters.maxPrice = 100;
  } else if (lowerMsg.includes('luxury') || lowerMsg.includes('expensive') || lowerMsg.includes('high-end') || lowerMsg.includes('premium')) {
    filters.price = 'luxury';
    filters.minPrice = 200;
  } else if (lowerMsg.includes('budget')) {
    filters.price = 'cheap';
    filters.maxPrice = 50;
  }
  
  // More robust exact price extraction
  const priceMatch = lowerMsg.match(/(under|below|less than|up to|about|around) (\$|€|£)?(\d+)/);
  if (priceMatch) {
    filters.maxPrice = Number(priceMatch[3]);
  }
  
  const exactPriceMatch = lowerMsg.match(/(\$|€|£)?(\d+)(\s|-)?(dollars|usd|eur|euros|pounds)?/);
  if (exactPriceMatch) {
    filters.exactPrice = Number(exactPriceMatch[2]);
  }

  // Improved recipient extraction with fuzzy matching
  giftEntities.recipient.forEach(recipient => {
    if (lowerMsg.includes(recipient) || 
        levenshteinDistance(lowerMsg, recipient) <= 2) {
      filters.recipient = recipient;
    }
  });

  // Improved occasion extraction
  giftEntities.occasion.forEach(occasion => {
    if (lowerMsg.includes(occasion) || 
        (occasion.includes(' ') && lowerMsg.includes(occasion.replace(' ', '')))) {
      filters.occasion = occasion;
    }
  });

  // Enhanced category extraction
  giftEntities.category.forEach(category => {
    if (lowerMsg.includes(category) || 
        (category.includes(' ') && lowerMsg.includes(category.replace(' ', '')))) {
      filters.category = category;
    }
  });

  // More comprehensive keyword extraction
  const keywords = [];
  const keywordMapping = {
    'watch': ['watch', 'smartwatch', 'timepiece'],
    'jewelry': ['ring', 'necklace', 'bracelet', 'earrings'],
    'book': ['book', 'novel', 'textbook', 'reading'],
    'electronics': ['tech', 'gadget', 'device', 'phone', 'tablet'],
    'home': ['decor', 'furniture', 'cushion', 'lamp']
  };
  
  Object.entries(keywordMapping).forEach(([category, terms]) => {
    terms.forEach(term => {
      if (lowerMsg.includes(term)) {
        keywords.push(category);
      }
    });
  });
  
  if (keywords.length) filters.keywords = [...new Set(keywords)];

  return filters;
}

// ====================== ENHANCED GIFT RECOMMENDATIONS ======================
async function getGiftRecommendations(filters) {
  const query = {};
  
  // Map filters to product schema fields
  if (filters.recipient) {
    query.recipientType = { $regex: filters.recipient, $options: 'i' };
  }
  if (filters.occasion) {
    query.occasion = { $regex: filters.occasion, $options: 'i' };
  }
  if (filters.category) {
    query.category = { $regex: filters.category, $options: 'i' };
  }
  if (filters.keywords) {
    query.$or = [
      { name: { $regex: filters.keywords.join('|'), $options: 'i' } },
      { description: { $regex: filters.keywords.join('|'), $options: 'i' } },
      { keywords: { $in: filters.keywords } }
    ];
  }
  
  // Enhanced price filtering
  if (filters.exactPrice) {
    query.price = { $gte: filters.exactPrice * 0.9, $lte: filters.exactPrice * 1.1 };
  } else {
    if (filters.maxPrice) {
      query.price = { ...query.price, $lte: filters.maxPrice };
    }
    if (filters.minPrice) {
      query.price = { ...query.price, $gte: filters.minPrice };
    }
  }

  try {
    return await Product.find(query)
      .sort({ popularity: -1, price: 1 })
      .limit(8)
      .select('name price description productUrl imageUrls recipientType occasion category');
  } catch (error) {
    console.error('Error fetching gift recommendations:', error);
    return [];
  }
}

// ====================== RESPONSE GENERATION ======================
async function generateResponse(intent, filters, products) {
  // Cute responses for social interactions
  const cuteResponses = {
    'greeting': [
      "Hello there! *waves* I'm your gift expert. Tell me who you're shopping for and I'll suggest perfect gifts!",
      "Hi friend! *smiles* Let's find an amazing gift together. Who's the lucky recipient?",
      "Hiiii! *excited* I love helping with gifts! What's the occasion we're shopping for?"
    ],
    'appreciation': [
      "You're so welcome! *happy dance* Let me know if you need more help!",
      "Aww, thanks! *blushes* I'm always happy to help with gift ideas!",
      "My pleasure! *beams* Don't hesitate to ask if you need more suggestions!"
    ],
    'gift.help': [
      "Of course! *claps* Tell me more about who we're shopping for!",
      "I'd love to help! *thinking* What's the occasion and budget?",
      "Yay! *excited* Gift shopping is my specialty! Who's the gift for?"
    ]
  };

  // Return cute response if available
  if (cuteResponses[intent]) {
    return cuteResponses[intent][Math.floor(Math.random() * cuteResponses[intent].length)];
  }

  // Handle no products found with better fallback
  if (!products.length) {
    const fallbacks = [
      "Hmm, I couldn't find exact matches *thinking*, but here are some popular gifts that might work:",
      "Let me think... *taps chin* While I couldn't find perfect matches, these are great options:",
      "I searched thoroughly! *determined* Here are some excellent alternatives:"
    ];
   const fallback = fallbacks[Math.floor(Math.random() * fallbacks.length)];
    
    // Get popular products that might fit the filters
    const fallbackQuery = {};
    if (filters.recipient) fallbackQuery.recipientType = { $regex: filters.recipient, $options: 'i' };
    if (filters.occasion) fallbackQuery.occasion = { $regex: filters.occasion, $options: 'i' };
    
    const popularProducts = await Product.find(fallbackQuery)
      .sort({ popularity: -1 })
      .limit(5)
      .select('name price productUrl imageUrls');
    
    if (popularProducts.length) {
      return fallback + "\n" + 
        popularProducts.map(p => 
          `- ${p.name} ($${p.price}) [View](${p.productUrl || '#'})`
        ).join('\n');
    } else {
      return "I couldn't find any matching gifts *sad face*. Could you tell me more about what you're looking for?";
    }
  }


  // Recipient-specific responses
  const recipientResponses = {
    'mother': [
      "For your amazing mom *heart* here are thoughtful gifts she'll love:",
      "Moms deserve the best! *nod* These would make her day special:",
      "What a wonderful child you are! *smile* For your dear mom:"
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
      "Birthdays are special! *party* Here are perfect gifts to celebrate:",
      "Make their birthday unforgettable with these great options:",
      "Birthday gifts that will bring smiles:"
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

  // Build response with more context
  let response = "I found these great options for you:";
  const intentParts = intent.split('.');
  const recipient = intentParts.find(part => recipientResponses[part]);
  const occasion = intentParts.find(part => occasionResponses[part]);

  if (recipient && occasion) {
    const recipientRes = recipientResponses[recipient][Math.floor(Math.random() * recipientResponses[recipient].length)];
    const occasionRes = occasionResponses[occasion][Math.floor(Math.random() * occasionResponses[occasion].length)];
    response = `${recipientRes} ${occasionRes}`;
  } else if (recipient) {
    response = recipientResponses[recipient][Math.floor(Math.random() * recipientResponses[recipient].length)];
  } else if (occasion) {
    response = occasionResponses[occasion][Math.floor(Math.random() * occasionResponses[occasion].length)];
  }

  // Format products with more details and better presentation
  return response + "\n" +
    products.map((p, index) => {
      let productText = `${index + 1}. **${p.name}** ($${p.price})`;
      if (p.description) productText += `\n   ${p.description.substring(0, 80)}${p.description.length > 80 ? '...' : ''}`;
      if (p.productUrl) productText += `\n   [View Product](${p.productUrl})`;
      if (p.imageUrls && p.imageUrls.length) productText += `\n   ![Image](${p.imageUrls[0]})`;
      return productText;
    }).join('\n\n');
}

module.exports = {
  classify: classifier.classify.bind(classifier),
    classify: classifyMessage,
  extractFiltersFromMessage,
  getGiftRecommendations,
  generateResponse
};

// ====================== EXPORTS ======================
module.exports = {
  classify: classifier.classify.bind(classifier),
  extractFiltersFromMessage,
  getGiftRecommendations,
  generateResponse
};