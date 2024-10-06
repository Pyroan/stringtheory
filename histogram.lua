-- some cute little functionality
-- for rendering sets of data <3
Histogram = {}
function Histogram:new(title, data, nbins)
    local o = {}
    self.__index = self
    setmetatable(o, self)

    o.title = title or "Untitled"
    nbins = nbins or 16
    self:initData(data, nbins)
    return o
end

function Histogram:initData(data, nbins)
    if #data < 1 then
        return
    end
    -- presort the data, duh
    table.sort(data)
    self.bins = {}
    for i = 1, nbins do
        self.bins[i] = {}
    end

    self.min = data[1]
    self.max = data[#data]

    if #data % 2 == 0 then
        self.median = (data[math.floor(#data / 2)] + data[math.ceil(#data / 2)]) / 2
    else
        self.median = data[math.ceil(#data / 2)]
    end
    -- you can recurse to gt q1 and q3 i just don't feel like it rn.
    -- o.q1=nil
    -- o.q3=nil

    -- calculate the mean and populate bins w/ the same pass.
    local sum = 0
    self.binwidth = (self.max - self.min) / nbins
    local cutoff = self.min
    local index = 0
    for i, v in ipairs(data) do
        sum = sum + v
        if v >= cutoff then
            cutoff = cutoff + self.binwidth
            index = index + 1
        end
        self.bins[index][#self.bins[index] + 1] = v
    end
    self.avg = sum / #data

    -- calculate standard deviation
    local variance = 0
    for _, v in ipairs(data) do
        variance = variance + (v - self.avg) * (v - self.avg)
    end
    self.stdev = math.sqrt(variance / #data)

    self.maxbincount = 0
    for i, v in ipairs(self.bins) do
        if #v > self.maxbincount then
            self.maxbincount = #v
        end
    end

    print("Error Data\n----------")
    print(string.format('min: %.3f', self.min))
    print(string.format('max: %.3f', self.max))
    print(string.format("avg: %.3f", self.avg))
    print(string.format('median: %.3f', self.median))
    print(string.format('\xE5: %.3f', self.stdev))
    print()
    print('bins' .. #self.bins)
    print('bin width:' .. self.binwidth)
end

function Histogram:draw(x, y, w, h)
    if self.bins ~= nil then
        local rectwidth = w / #self.bins
        for i, v in ipairs(self.bins) do
            love.graphics.setColor(HSL(i / #self.bins, 1, 0.5, 0.5))

            local colheight = math.max(h * #v / self.maxbincount, 1)
            love.graphics.rectangle("fill", x + ((i - 1) * rectwidth), y + h - colheight, rectwidth, colheight)
        end
    end
end
