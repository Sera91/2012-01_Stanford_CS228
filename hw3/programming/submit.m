function submit(partId)
%SUBMIT Submit your code and output to the pgm-class servers
%   SUBMIT() will connect to the pgm-class server and submit your solution
%   There is no penalty for submitting, so go ahead and try this!

  fprintf('==\n== [pgm-class] Submitting Solutions | Programming Assignment %s\n==\n', ...
          homework_id());
  if ~exist('partId', 'var') || isempty(partId)
    partId = promptPart();
  end
  
  % Check valid partId
  partNames = validParts();
  if ~isValidPartId(partId)
    fprintf('!! Invalid assignment part selected.\n');
    fprintf('!! Expected an integer from 1 to %d.\n', numel(partNames) + 1);
    fprintf('!! Submission Cancelled\n');
    return
  end

  [login password] = loginPrompt();
  if isempty(login)
    fprintf('!! Submission Cancelled\n');
    return
  end

  fprintf('\n== Connecting to pgm-class ... '); 
  if exist('OCTAVE_VERSION') 
    fflush(stdout);
  end
  
  % Setup submit list
  if partId == numel(partNames) + 1
    submitParts = 1:numel(partNames);
  else
    submitParts = [partId];
  end

  for s = 1:numel(submitParts)
    % Submit this part
    partId = submitParts(s);
    
    samplePartId = 2 * (partId - 1) + 1;
    testPartId = samplePartId + 1;
    
    for thisPartId = [samplePartId testPartId]
        [login, ch, signature, auxstring] = getChallenge(login, thisPartId);
        if isempty(login) || isempty(ch) || isempty(signature)
            % Some error occured, error string in first return element.
            fprintf('\n!! Error: %s\n\n', login);
            return
        end
        
        % Attempt Submission with Challenge
        ch_resp = challengeResponse(login, password, ch);
        
        [result, str] = submitSolution(login, ch_resp, thisPartId, ...
            output(thisPartId, auxstring), source(partId), signature);
        
        if (thisPartId == samplePartId)
            partName = partNames{partId};
        else
            partName = [partNames{partId} ' (test)'];
            if (length(str) >= 5 && strcmp(str(1:5), 'Sorry'))
                str = 'We have received your submission.';
            end
        end
        
        fprintf('\n== [pgm-class] Submitted Assignment %s - Part %d - %s\n', ...
            homework_id(), partId, partName);
        fprintf('== %s\n', strtrim(str));
        
        if exist('OCTAVE_VERSION')
            fflush(stdout);
        end
    end
    
  end
  
end

% ================== CONFIGURABLES FOR EACH HOMEWORK ==================

function id = homework_id() 
  id = '3';
end

function [partNames] = validParts()
  partNames = { 'ComputeSingletonFactors', ...
                'ComputeWordPredictions', ...
                'ComputePairwiseFactors', ...
                'ComputeTripletFactors', ...
                'ComputeSimilarityFactor', ...
                'ComputeAllSimilarityFactors', ...
                'ChooseTopSimilarityFactors'
              };
end

function srcs = sources()
  % Separated by part
  srcs = { { 'ComputeSingletonFactors.m', 'partner.txt' }, ...
           { 'ComputeWordPredictions.m', 'partner.txt' }, ...
           { 'ComputePairwiseFactors.m', 'partner.txt' }, ...
           { 'ComputeTripletFactors.m', 'partner.txt' }, ...
           { 'ComputeSimilarityFactor.m', 'partner.txt' }, ...
           { 'ComputeAllSimilarityFactors.m', 'partner.txt' }, ...
           { 'ChooseTopSimilarityFactors.m', 'partner.txt' }, ...
         };
end

function out = output(partId, auxstring)
if exist('OCTAVE_VERSION')
    UnserializeFactorsFg = @UnserializeFactorsFgOctave;
else
    UnserializeFactorsFg = @UnserializeFactorsFgMATLAB;
end


load PA3Models.mat;
load PA3SampleCases.mat;

if partId == 1
    images = Part1SampleImagesInput;
    factors = ComputeSingletonFactors(images, imageModel);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 2
    images = UnserializeWordImages(auxstring);
    factors = ComputeSingletonFactors(images, imageModel);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 3
    allWords = Part2SampleWordsInput;
    imageModel.ignoreSimilarity = 1;
    words = ComputeWordPredictions(allWords, imageModel, [], []);
    out = SerializeWordList(words);
elseif partId == 4
    allWords = UnserializeAllWords(auxstring);
    imageModel.ignoreSimilarity = 1;
    words = ComputeWordPredictions(allWords, imageModel, [], []);
    out = SerializeWordList(words);
elseif partId == 5
    images = Part3SampleImagesInput;
    factors = ComputePairwiseFactors(images, pairwiseModel, imageModel.K);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 6
    images = UnserializeWordImages(auxstring);
    factors = ComputePairwiseFactors(images, pairwiseModel, imageModel.K);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 7
    images = Part4SampleImagesInput;
    factors = ComputeTripletFactors(images, tripletList, imageModel.K);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 8
    images = UnserializeWordImages(auxstring);
    factors = ComputeTripletFactors(images, tripletList, imageModel.K);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 9
    images = Part5SampleImagesInput;
    factor = ComputeSimilarityFactor(images, imageModel.K, 1, 2);
    factor = SortAllFactors(factor);
    out = SerializeFactorsFg(factor);
elseif partId == 10
    images = UnserializeWordImages(auxstring);
    factor = ComputeSimilarityFactor(images, imageModel.K, 3, 4);
    factor = SortAllFactors(factor);
    out = SerializeFactorsFg(factor);
elseif partId == 11
    images = Part6SampleImagesInput;
    factors = ComputeAllSimilarityFactors(images, imageModel.K);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 12
    images = UnserializeWordImages(auxstring);
    factors = ComputeAllSimilarityFactors(images, imageModel.K);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 13
    allFactors = Part7SampleFactorsInput;
    factors = ChooseTopSimilarityFactors(allFactors, 2);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
elseif partId == 14
    allFactors = UnserializeFactorsFg(auxstring);
    factors = ChooseTopSimilarityFactors(allFactors, 2);
    factors = SortAllFactors(factors);
    out = SerializeFactorsFg(factors);
end
end

function out = SerializeFactorsFg(F)
% Serializes a factor struct array into the .fg format for libDAI
% http://cs.ru.nl/~jorism/libDAI/doc/fileformats.html
%
% To avoid incompatibilities with EOL markers, make sure you write the
% string to a file using the appropriate file type ('wt' for windows, 'w'
% for unix)

lines = cell(5*numel(F) + 1, 1);

lines{1} = sprintf('%d\n', numel(F));
lineIdx = 2;
for i = 1:numel(F)
  lines{lineIdx} = sprintf('\n%d\n', numel(F(i).var));
  lineIdx = lineIdx + 1;
  
  lines{lineIdx} = sprintf('%s\n', num2str(F(i).var(:)')); % ensure that we put in a row vector
  lineIdx = lineIdx + 1;
  
  lines{lineIdx} = sprintf('%s\n', num2str(F(i).card(:)')); % ensure that we put in a row vector
  lineIdx = lineIdx + 1;
  
  lines{lineIdx} = sprintf('%d\n', numel(F(i).val));
  lineIdx = lineIdx + 1;
  
  % Internal storage of factor vals is already in the same indexing order
  % as what libDAI expects, so we don't need to convert the indices.
  vals = [0:(numel(F(i).val) - 1); F(i).val(:)'];
  lines{lineIdx} = sprintf('%d %0.8g\n', vals);
  lineIdx = lineIdx + 1;
end

out = sprintf('%s', lines{:});

end

function F = UnserializeFactorsFgOctave(str)
%UnserializeFactorsFg Converts a string representing factors in the libDAI
%.fg format into a struct array of factors
% http://cs.ru.nl/~jorism/libDAI/doc/fileformats.html
% Rewritten for Octave compatibility using strtok instead of textscan
% In Octave, double quoted strings allow for escape sequences!

[tok, str] = strtok(str);
numFactors = sscanf(tok, '%d');

F(numFactors) = struct('var', [], 'card', [], 'val', []);

for i = 1:numFactors
  [tok, str] = strtok(str);
  numVar = sscanf(tok, '%d');

  F(i).var = zeros(1, numVar);
  F(i).card = zeros(1, numVar);
  
  for j = 1:numVar
    [tok, str] = strtok(str);
    F(i).var(j) = sscanf(tok, '%f');
  end
  
  for j = 1:numVar
    [tok, str] = strtok(str);
    F(i).card(j) = sscanf(tok, '%f');      
  end
  
  [tok, str] = strtok(str);
  nnz = sscanf(tok, '%d');
        
  % libDAI's .fg format assumes that non-specified entries are zeros.
  % In addition, although the ordering of values is the same as in our 228
  % factor format, the indices start from 0 in the .fg format.
  F(i).val = zeros(prod(F(i).card), 1);
  
  for j = 1:nnz
    [tok, str] = strtok(str);
    idx = sscanf(tok, '%d');
  
    [tok, str] = strtok(str);
    val = sscanf(tok, '%f');
    
    F(i).val(idx + 1) = val;
  end  
end

end

function F = UnserializeFactorsFgMATLAB(str)
%UnserializeFactorsFg Converts a string representing factors in the libDAI
%.fg format into a struct array of factors
% http://cs.ru.nl/~jorism/libDAI/doc/fileformats.html

[numFactors, pos] = textscan(str, '%d', 1);
idx = pos;
numFactors = numFactors{1};

F(numFactors) = struct('var', [], 'card', [], 'val', []);

for i = 1:numFactors
  [numVar, pos] = textscan(str(idx+1:end), '%d', 1);
  idx = idx + pos;  
  numVar = numVar{1};
  
  [var, pos] = textscan(str(idx+1:end), '%f', numVar);
  idx = idx + pos;
  
  [card, pos] = textscan(str(idx+1:end), '%f', numVar);
  idx = idx + pos;
    
  [nnz, pos] = textscan(str(idx+1:end), '%d', 1);
  idx = idx + pos;
  nnz = nnz{1};
  
  [entries, pos] = textscan(str(idx+1:end), '%d %f', nnz);
  idx = idx + pos;
  
  F(i).var = var{:}';
  F(i).card = card{:}';
  
  % libDAI's .fg format assumes that non-specified entries are zeros.
  % In addition, although the ordering of values is the same as in our 228
  % factor format, the indices start from 0 in the .fg format.
  F(i).val = zeros(prod(F(i).card), 1);
  F(i).val(entries{1} + 1) = entries{2};
end

end

function f = SortAllFactors(factors)

for i = 1:length(factors)
    factors(i) = SortFactorVars(factors(i));
end

varMat = vertcat(factors(:).var);
[unused, order] = sortrows(varMat);

f = factors(order);

end

function G = SortFactorVars(F)

[sortedVars, order] = sort(F.var);
G.var = sortedVars;

G.card = F.card(order);
G.val = zeros(numel(F.val), 1);

assignmentsInF = IndexToAssignment(1:numel(F.val), F.card);
assignmentsInG = assignmentsInF(:,order);
G.val(AssignmentToIndex(assignmentsInG, G.card)) = F.val;

end

function str = SerializeAllWords (allWords)

n = length(allWords);
str = [];
for i = 1:n
    word = char(horzcat(allWords{i}(:).groundTruth) + 'a' - 1);
    str = [str SerializeWordImages(allWords{i})];
    
    str = [str '-' word '~'];
end

end

function str = SerializeWordImages(images)

n = length(images);
str = [];

for i = 1:n
    str = [str char('a' + images(i).img(:)') 'c'];    
end

end

function str = SerializeWordList (words)

str = [];
for i = 1:length(words)
    str = [str num2str(words{i}(:)') '  ']; %#ok
end

end

function allWords = UnserializeAllWords (str)

numWords = sum(str == '~');
allWords = cell(numWords, 1);

endIdxs = find(str == '~');
dashLocs = find(str == '-');

for i = 1:numWords
    if (i == 1)
        imagesStart = 1;
    else
        imagesStart = endIdxs(i-1) + 1;
    end
    imagesEnd = dashLocs(i) - 1;
    wordStart = dashLocs(i) + 1;
    wordEnd = endIdxs(i) - 1;
    word = str(wordStart:wordEnd);
    
    allWords{i} = UnserializeWordImages(str(imagesStart:imagesEnd));
    for j = 1:length(allWords{i})
        allWords{i}(j).groundTruth = word(j) - 'a' + 1;
    end
    
end

end

function images = UnserializeWordImages (str)

numImages = sum(str == 'c');
images(numImages).img = [];


endIdxs = find(str == 'c');
for i = 1:numImages
    if (i == 1)
        startIdx = 1;
    else
        startIdx = endIdxs(i-1) + 1;
    end
    imChars = str(startIdx:endIdxs(i)-1);
    im = reshape(double(imChars - 'a'), 16, 8);
    images(i).img = im;
end

images = images(:); % make sure it's column

end



%%% Remove -staging when you deploy!
function url = challenge_url()
  url = 'http://stanford.campus-class.org/pgm/assignment/challenge';
end

%%% Remove -staging when you deploy!
function url = submit_url()
  url = 'http://stanford.campus-class.org/pgm/assignment/submit';
end

% ========================= CHALLENGE HELPERS =========================

function src = source(partId)
  src = '';
  src_files = sources();
  if partId <= numel(src_files)
      flist = src_files{partId};
      for i = 1:numel(flist)
          fid = fopen(flist{i});
          if (fid == -1) 
            error('Error opening %s (is it missing?)', flist{i});
          end
          line = fgets(fid);
          while ischar(line)
            src = [src line];            
            line = fgets(fid);
          end
          fclose(fid);
          src = [src '||||||||'];
      end
  end
end

function ret = isValidPartId(partId)
  partNames = validParts();
  ret = (~isempty(partId)) && (partId >= 1) && (partId <= numel(partNames) + 1);
end

function partId = promptPart()
  fprintf('== Select which part(s) to submit:\n', ...
          homework_id());
  partNames = validParts();
  srcFiles = sources();
  for i = 1:numel(partNames)
    fprintf('==   %d) %s [', i, partNames{i});
    fprintf(' %s ', srcFiles{i}{:});
    fprintf(']\n');
  end
  fprintf('==   %d) All of the above \n==\nEnter your choice [1-%d]: ', ...
          numel(partNames) + 1, numel(partNames) + 1);
  selPart = input('', 's');
  partId = str2num(selPart);
  if ~isValidPartId(partId)
    partId = -1;
  end
end

function [email,ch,signature,auxstring] = getChallenge(email, part)
  str = urlread(challenge_url(), 'post', {'email_address', email, 'assignment_part_sid', [homework_id() '-' num2str(part)], 'response_encoding', 'delim'});

  str = strtrim(str);
  r = struct;
  while(numel(str) > 0)
    [f, str] = strtok (str, '|');
    [v, str] = strtok (str, '|');
    r = setfield(r, f, v);
  end

  email = getfield(r, 'email_address');
  ch = getfield(r, 'challenge_key');
  signature = getfield(r, 'state');
  auxstring = getfield(r, 'challenge_aux_data');
end


function [result, str] = submitSolution(email, ch_resp, part, output, ...
                                        source, signature)

  params = {'assignment_part_sid', [homework_id() '-' num2str(part)], ...
            'email_address', email, ...
            'submission', base64encode(output, ''), ...
            'submission_aux', base64encode(source, ''), ...
            'challenge_response', ch_resp, ...
            'state', signature};

  str = urlread(submit_url(), 'post', params);
 
  % Parse str to read for success / failure
  result = 0;

end

% =========================== LOGIN HELPERS ===========================

function [login password] = loginPrompt()
  % Prompt for password
  [login password] = basicPrompt();
  
  if isempty(login) || isempty(password)
    login = []; password = [];
  end
end


function [login password] = basicPrompt()
  login = 'dbtsai@stanford.edu' %input('Login (Email address): ', 's');
  password = 'Whp65Rrtgs'       %input('Submission Password (from Assignments page): ', 's');
end


function [str] = challengeResponse(email, passwd, challenge)
  str = sha1([challenge passwd]);
end


% =============================== SHA-1 ================================

function hash = sha1(str)
  
  % Initialize variables
  h0 = uint32(1732584193);
  h1 = uint32(4023233417);
  h2 = uint32(2562383102);
  h3 = uint32(271733878);
  h4 = uint32(3285377520);
  
  % Convert to word array
  strlen = numel(str);

  % Break string into chars and append the bit 1 to the message
  mC = [double(str) 128];
  mC = [mC zeros(1, 4-mod(numel(mC), 4), 'uint8')];
  
  numB = strlen * 8;
  if exist('idivide')
    numC = idivide(uint32(numB + 65), 512, 'ceil');
  else
    numC = ceil(double(numB + 65)/512);
  end
  numW = numC * 16;
  mW = zeros(numW, 1, 'uint32');
  
  idx = 1;
  for i = 1:4:strlen + 1
    mW(idx) = bitor(bitor(bitor( ...
                  bitshift(uint32(mC(i)), 24), ...
                  bitshift(uint32(mC(i+1)), 16)), ...
                  bitshift(uint32(mC(i+2)), 8)), ...
                  uint32(mC(i+3)));
    idx = idx + 1;
  end
  
  % Append length of message
  mW(numW - 1) = uint32(bitshift(uint64(numB), -32));
  mW(numW) = uint32(bitshift(bitshift(uint64(numB), 32), -32));

  % Process the message in successive 512-bit chs
  for cId = 1 : double(numC)
    cSt = (cId - 1) * 16 + 1;
    cEnd = cId * 16;
    ch = mW(cSt : cEnd);
    
    % Extend the sixteen 32-bit words into eighty 32-bit words
    for j = 17 : 80
      ch(j) = ch(j - 3);
      ch(j) = bitxor(ch(j), ch(j - 8));
      ch(j) = bitxor(ch(j), ch(j - 14));
      ch(j) = bitxor(ch(j), ch(j - 16));
      ch(j) = bitrotate(ch(j), 1);
    end
  
    % Initialize hash value for this ch
    a = h0;
    b = h1;
    c = h2;
    d = h3;
    e = h4;
    
    % Main loop
    for i = 1 : 80
      if(i >= 1 && i <= 20)
        f = bitor(bitand(b, c), bitand(bitcmp(b), d));
        k = uint32(1518500249);
      elseif(i >= 21 && i <= 40)
        f = bitxor(bitxor(b, c), d);
        k = uint32(1859775393);
      elseif(i >= 41 && i <= 60)
        f = bitor(bitor(bitand(b, c), bitand(b, d)), bitand(c, d));
        k = uint32(2400959708);
      elseif(i >= 61 && i <= 80)
        f = bitxor(bitxor(b, c), d);
        k = uint32(3395469782);
      end
      
      t = bitrotate(a, 5);
      t = bitadd(t, f);
      t = bitadd(t, e);
      t = bitadd(t, k);
      t = bitadd(t, ch(i));
      e = d;
      d = c;
      c = bitrotate(b, 30);
      b = a;
      a = t;
      
    end
    h0 = bitadd(h0, a);
    h1 = bitadd(h1, b);
    h2 = bitadd(h2, c);
    h3 = bitadd(h3, d);
    h4 = bitadd(h4, e);

  end

  hash = reshape(dec2hex(double([h0 h1 h2 h3 h4]), 8)', [1 40]);
  
  hash = lower(hash);

end

function ret = bitadd(iA, iB)
  ret = double(iA) + double(iB);
  ret = bitset(ret, 33, 0);
  ret = uint32(ret);
end

function ret = bitrotate(iA, places)
  t = bitshift(iA, places - 32);
  ret = bitshift(iA, places);
  ret = bitor(ret, t);
end

% =========================== Base64 Encoder ============================
% Thanks to Peter John Acklam
%

function y = base64encode(x, eol)
%BASE64ENCODE Perform base64 encoding on a string.
%
%   BASE64ENCODE(STR, EOL) encode the given string STR.  EOL is the line ending
%   sequence to use; it is optional and defaults to '\n' (ASCII decimal 10).
%   The returned encoded string is broken into lines of no more than 76
%   characters each, and each line will end with EOL unless it is empty.  Let
%   EOL be empty if you do not want the encoded string broken into lines.
%
%   STR and EOL don't have to be strings (i.e., char arrays).  The only
%   requirement is that they are vectors containing values in the range 0-255.
%
%   This function may be used to encode strings into the Base64 encoding
%   specified in RFC 2045 - MIME (Multipurpose Internet Mail Extensions).  The
%   Base64 encoding is designed to represent arbitrary sequences of octets in a
%   form that need not be humanly readable.  A 65-character subset
%   ([A-Za-z0-9+/=]) of US-ASCII is used, enabling 6 bits to be represented per
%   printable character.
%
%   Examples
%   --------
%
%   If you want to encode a large file, you should encode it in chunks that are
%   a multiple of 57 bytes.  This ensures that the base64 lines line up and
%   that you do not end up with padding in the middle.  57 bytes of data fills
%   one complete base64 line (76 == 57*4/3):
%
%   If ifid and ofid are two file identifiers opened for reading and writing,
%   respectively, then you can base64 encode the data with
%
%      while ~feof(ifid)
%         fwrite(ofid, base64encode(fread(ifid, 60*57)));
%      end
%
%   or, if you have enough memory,
%
%      fwrite(ofid, base64encode(fread(ifid)));
%
%   See also BASE64DECODE.

%   Author:      Peter John Acklam
%   Time-stamp:  2004-02-03 21:36:56 +0100
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   if isnumeric(x)
      x = num2str(x);
   end

   % make sure we have the EOL value
   if nargin < 2
      eol = sprintf('\n');
   else
      if sum(size(eol) > 1) > 1
         error('EOL must be a vector.');
      end
      if any(eol(:) > 255)
         error('EOL can not contain values larger than 255.');
      end
   end

   if sum(size(x) > 1) > 1
      error('STR must be a vector.');
   end

   x   = uint8(x);
   eol = uint8(eol);

   ndbytes = length(x);                 % number of decoded bytes
   nchunks = ceil(ndbytes / 3);         % number of chunks/groups
   nebytes = 4 * nchunks;               % number of encoded bytes

   % add padding if necessary, to make the length of x a multiple of 3
   if rem(ndbytes, 3)
      x(end+1 : 3*nchunks) = 0;
   end

   x = reshape(x, [3, nchunks]);        % reshape the data
   y = repmat(uint8(0), 4, nchunks);    % for the encoded data

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Split up every 3 bytes into 4 pieces
   %
   %    aaaaaabb bbbbcccc ccdddddd
   %
   % to form
   %
   %    00aaaaaa 00bbbbbb 00cccccc 00dddddd
   %
   y(1,:) = bitshift(x(1,:), -2);                  % 6 highest bits of x(1,:)

   y(2,:) = bitshift(bitand(x(1,:), 3), 4);        % 2 lowest bits of x(1,:)
   y(2,:) = bitor(y(2,:), bitshift(x(2,:), -4));   % 4 highest bits of x(2,:)

   y(3,:) = bitshift(bitand(x(2,:), 15), 2);       % 4 lowest bits of x(2,:)
   y(3,:) = bitor(y(3,:), bitshift(x(3,:), -6));   % 2 highest bits of x(3,:)

   y(4,:) = bitand(x(3,:), 63);                    % 6 lowest bits of x(3,:)

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Now perform the following mapping
   %
   %   0  - 25  ->  A-Z
   %   26 - 51  ->  a-z
   %   52 - 61  ->  0-9
   %   62       ->  +
   %   63       ->  /
   %
   % We could use a mapping vector like
   %
   %   ['A':'Z', 'a':'z', '0':'9', '+/']
   %
   % but that would require an index vector of class double.
   %
   z = repmat(uint8(0), size(y));
   i =           y <= 25;  z(i) = 'A'      + double(y(i));
   i = 26 <= y & y <= 51;  z(i) = 'a' - 26 + double(y(i));
   i = 52 <= y & y <= 61;  z(i) = '0' - 52 + double(y(i));
   i =           y == 62;  z(i) = '+';
   i =           y == 63;  z(i) = '/';
   y = z;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Add padding if necessary.
   %
   npbytes = 3 * nchunks - ndbytes;     % number of padding bytes
   if npbytes
      y(end-npbytes+1 : end) = '=';     % '=' is used for padding
   end

   if isempty(eol)

      % reshape to a row vector
      y = reshape(y, [1, nebytes]);

   else

      nlines = ceil(nebytes / 76);      % number of lines
      neolbytes = length(eol);          % number of bytes in eol string

      % pad data so it becomes a multiple of 76 elements
      y = [y(:) ; zeros(76 * nlines - numel(y), 1)];
      y(nebytes + 1 : 76 * nlines) = 0;
      y = reshape(y, 76, nlines);

      % insert eol strings
      eol = eol(:);
      y(end + 1 : end + neolbytes, :) = eol(:, ones(1, nlines));

      % remove padding, but keep the last eol string
      m = nebytes + neolbytes * (nlines - 1);
      n = (76+neolbytes)*nlines - neolbytes;
      y(m+1 : n) = '';

      % extract and reshape to row vector
      y = reshape(y, 1, m+neolbytes);

   end

   % output is a character array
   y = char(y);

end
