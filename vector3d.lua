--[[
Copyright (c) 2010-2012 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

Except as contained in this notice, the name(s) of the above copyright holders
shall not be used in advertising or otherwise to promote the sale, use or
other dealings in this Software without prior written authorization.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--

--[[
Taken from hump lib and modified for 3d usage
]]--

local assert = assert
local sqrt, cos, sin, acos, asin, pi = math.sqrt, math.cos, math.sin, math.acos, math.asin, math.pi

local vector = {}
vector.__index = vector

local function new(x,y,z)
	local v = {x = x or 0, y = y or 0, z = z or 0}
	setmetatable(v, vector)
	return v
end

local function isvector(v)
	return getmetatable(v) == vector
end

function vector:clone()
	return new(self.x, self.y, self.z)
end

function vector:unpack()
	return self.x, self.y, self.z
end

function vector:__tostring()
	return "("..tonumber(self.x)..","..tonumber(self.y)..","..tonumber(self.z)..")"
end

function vector.__unm(a)
	return new(-a.x, -a.y, -a.z)
end

function vector.__add(a,b)
	assert(isvector(a) and isvector(b), "Add: wrong argument types (<vector> expected)")
	return new(a.x+b.x, a.y+b.y, a.z+b.z)
end

function vector.__sub(a,b)
	assert(isvector(a) and isvector(b), "Sub: wrong argument types (<vector> expected)")
	return new(a.x-b.x, a.y-b.y, a.z-b.z)
end

function vector.__mul(a,b)
	if type(a) == "number" then
		return new(a*b.x, a*b.y, a*b.z)
	elseif type(b) == "number" then
		return new(b*a.x, b*a.y, b*a.z)
	else
		assert(isvector(a) and isvector(b), "Mul: wrong argument types (<vector> or <number> expected)")
		return a.x*b.x + a.y*b.y + a.z*b.z
	end
end

function vector.__div(a,b)
	assert(isvector(a) and type(b) == "number", "wrong argument types (expected <vector> / <number>)")
	return new(a.x / b, a.y / b, a.z / b)
end

function vector.__eq(a,b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

function vector.__lt(a,b)
	error("unimplemented")
	--return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function vector.__le(a,b)
	return a.x <= b.x and a.y <= b.y and a.z <= b.z
end

function vector.permul(a,b)
	assert(isvector(a) and isvector(b), "permul: wrong argument types (<vector> expected)")
	return new(a.x*b.x, a.y*b.y, a.z*b.z)
end

function vector:len2()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

function vector:len()
	return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

function vector.dist(a, b)
	assert(isvector(a) and isvector(b), "dist: wrong argument types (<vector> expected)")
	local dx = a.x - b.x
	local dy = a.y - b.y
	local dz = a.z - b.z
	return sqrt(dx * dx + dy * dy + dz * dz)
end

function vector:normalize_inplace()
	local l = self:len()
	self.x, self.y, self.z = self.x / l, self.y / l, self.z / l
	return self
end

function vector:normalized()
	return self / self:len()
end

function vector:spherical()
	local r = self:len()
	local phi = acos(self.z/r)
	local theta
	if self.y >= 0 then
		theta = acos(self.x/r)
	else
		theta = 2*pi - acos(self.x/r)
	end
	return r,phi,theta
end

function cartesian(r, phi, theta)
	local x = r * sin(phi) * cos(theta)
	local y = r * sin(phi) * sin(theta)
	local z = r * cos(phi)
	return x,y,z
end

function vector:cartesian_inplace(r, phi, theta)
	self.x, self.y, self.z = cartesian(r,phi,theta)
end

function vector:rotate_around(phi, v)
	local c, s = cos(phi),sin(phi)
end

function vector:yaw_inplace(theta)
	local c, s = cos(theta),sin(theta)
	self.x,self.y = c * self.x - s * self.y, s * self.x + c * self.y
end

function vector:yawed(theta)
	local c, s = cos(theta),sin(theta)
	return new(c * self.x - s * self.y, s * self.x + c * self.y, self.z)
end

function vector:pitch_inplace(theta)
	local c, s = cos(theta),sin(theta)
	self.x,self.z = c * self.x + s * self.z, - s * self.x + c * self.z
end

function vector:rotated(phi, theta)
	local r,vphi,vtheta = self:spherical()
	return new(cartesian(r, vphi+phi, vtheta+theta))
end

function vector:perpendicular()
	return new(-self.y, self.x, self.z)
end

function vector:projectOn(v)
	error("unimplemented")
	--assert(isvector(v), "invalid argument: cannot project vector on " .. type(v))
	--local s = (self.x * v.x + self.y * v.y + self.z * v.z) / (v.x * v.x + v.y * v.y + v.z * v.z)
	--return new(s * v.x, s * v.y, s * v.z)
end

function vector:mirrorOn(v)
	error("unimplemented")
	--assert(isvector(v), "invalid argument: cannot mirror vector on " .. type(v))
	-- 2 * self:projectOn(v) - self
	--local s = 2 * (self.x * v.x + self.y * v.y) / (v.x * v.x + v.y * v.y)
	--return new(s * v.x - self.x, s * v.y - self.y)
end

function vector:cross(v)
	assert(isvector(v), "cross: wrong argument types (<vector> expected)")
	local x = self.y * v.z - self.z * v.y
	local y = self.z * v.x - self.x * v.z
	local z = self.x * v.y - self.y * v.x
	return new(x,y,z)
end


-- the module
return setmetatable({new = new, isvector = isvector},
	{__call = function(_, ...) return new(...) end})
